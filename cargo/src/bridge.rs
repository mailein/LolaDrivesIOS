use core::time::Duration;
use ordered_float::NotNan;
use rtlola_frontend::ParserConfig;
use rtlola_interpreter::{EvalConfig, Incremental, Monitor, TimeFormat, TimeRepresentation, Value};
use core::f64;
use std::os::raw::{c_char, c_uint, c_int, c_long};
use std::ffi::{CStr};
use std::mem;

/// Represents the monitor, should only be an opaque pointer in Kotlin.
pub struct KotlinMonitor {
    monitor: Monitor<Incremental>,
    relevant_ixs: Vec<usize>,
    num_inputs: usize,
}

/// Initializes a monitor for a given spec.
///
/// The `spec` is a string representation of the specification. The `relevant_output` argument is a string containing
/// the names of all relevant output streams, separated by commas.  Only the outputs of these streams will be reported by the monitor.
#[no_mangle]
pub unsafe extern "C" fn init(
    spec: *mut c_char,
    relevant_outputs: *mut c_char,
) -> KotlinMonitor {
    let spec = {
        if spec.is_null() { panic!() }
        // CString::from_raw(s)
        let c_str = { CStr::from_ptr(spec) };
        let recipient = match c_str.to_str() {
            Err(_) => "spec error",
            Ok(string) => string,
        };
        recipient
    };
    let relevant_outputs = {
       if relevant_outputs.is_null() { panic!() }
       // CString::from_raw(s)
       let c_str = { CStr::from_ptr(relevant_outputs) };
       let recipient = match c_str.to_str() {
           Err(_) => "relevant outputs error",
           Ok(string) => string,
       };
       recipient
    };

    let ir = rtlola_frontend::parse(ParserConfig::for_string(spec.to_string())).unwrap();
    let ec = EvalConfig::api(TimeRepresentation::Relative(TimeFormat::HumanTime));

    let relevant_ixs = relevant_outputs
        .split(',')
        .map(|name| {
            ir.outputs
                .iter()
                .find(|o| o.name == name)
                .expect("ir does not contain required output stream")
                .reference
                .out_ix()
        })
        .collect();

    let num_inputs = ir.inputs.len();
    let m: Monitor<Incremental> = rtlola_interpreter::Config::new_api(ec, ir).as_api();
    let monitor = KotlinMonitor {
        monitor: m,
        relevant_ixs,
        num_inputs,
    };

    //Box::into_raw(Box::new(monitor))
    monitor
}

/// Receives a single event and returns an array of verdicts.
///
/// Interprets the `monitor` input as pointer to a `KotlinMonitor` received via the `init` function.
/// The `input` argument contains a long value for each input of the specification plus the current timestamp at the end.
#[no_mangle]
pub unsafe extern "C" fn receive_single_value(
    monitor: c_long,
    input_ix: c_int,
    value: f64,
    timestamp: f64,
    len_out: *mut c_uint
) -> *mut f64 {
    let mut mon = unsafe { Box::from_raw(monitor as *mut KotlinMonitor) };
    let mut event = vec![Value::None; mon.num_inputs];
    event[input_ix as usize] = Value::Float(NotNan::new(value).unwrap());
    process_event(&mut mon, &event, timestamp, len_out)
}

/// Receives a single event and returns an array of verdicts.
///
/// Interprets the `monitor` input as pointer to a `KotlinMonitor` received via the `init` function.
/// The `input` argument contains a long value for each input of the specification plus the current timestamp at the end.
#[no_mangle]
pub unsafe extern "C" fn receive_total_event(
    mon: &mut KotlinMonitor,
    inputs: *mut f64,
    len_out: *mut c_uint
) -> *mut f64 {
    //let mut mon = unsafe { Box::from_raw(monitor as *mut KotlinMonitor) };
    let num_values = mon.num_inputs + 1;
    let inputs = std::slice::from_raw_parts(inputs, num_values as usize).to_vec();
    //println!("***********   rust inputs: {:?}", inputs);
    //TODO
    //debug_assert!(inputs.is_ok());
    //if inputs.is_err() {
        // In release config, ignore invalid inputs.
        //*len_out = 1;
        //return &vec![0.0; 1];
    //}

    let (time, inputs) = inputs.split_last().unwrap();
    let inputs = inputs
        .iter()
        .copied()
        .map(|f| Value::Float(NotNan::new(f).unwrap()))
        .collect::<Vec<_>>();
    let ret = process_event(mon, &inputs, *time, len_out);
    //println!("***********   rust outputs: {:?}", std::slice::from_raw_parts(ret, *len_out as usize).to_vec());
    return ret
}

/// Receives a single event and returns an array of verdicts.
///
/// Interprets the `monitor` input as pointer to a `KotlinMonitor` received via the `init` function.
/// The `input` argument contains a long value for each input of the specification plus the current timestamp at the end.
/// The `active` argument is a bool array where a `true` value at position `ix` indicates that the `ix`th value of
/// `input` contains a meaningful new value.  All other values will be ignored.
/// The timestamp must always be active, so the following invariant must hold:
/// `len(inputs) == len(active) && last(active) || len(inputs) == len(active) + 1
#[no_mangle]
pub unsafe extern "C" fn receive_partial_event(
    monitor: c_long,
    inputs: *mut f64,
    active: *mut bool,
    len_out: *mut c_uint
) -> *mut f64 {
    let mut mon = unsafe { Box::from_raw(monitor as *mut KotlinMonitor) };
    let num_values = mon.num_inputs + 1;

    let inputs = std::slice::from_raw_parts(inputs, num_values as usize).to_vec();
    let active = std::slice::from_raw_parts(active, num_values as usize).to_vec();
    //TODO
    // crash in debug
    //debug_assert!(inputs.is_ok());
    //debug_assert!(active.is_ok());
    //if active.is_err() || inputs.is_err() {
        // In release config, ignore invalid inputs.
        //return env.new_double_array(0).unwrap();
    //}

    let (time, input) = inputs.split_last().unwrap();

    let event: Vec<Value> = input
        .iter()
        .zip(active)
        .map(|(f, a)| if a { Value::Float(NotNan::new(*f).unwrap()) } else { Value::None })
        .collect();
    process_event(&mut mon, &event, *time, len_out)
}

unsafe fn process_event(
    mon: &mut KotlinMonitor,
    event: &[Value],
    time: f64,
    len_out: *mut c_uint
) -> *mut f64 {
    let updates = mon
        .monitor
        .accept_event(event, Duration::new(time.floor() as u64, 0));

    let num_updates = updates.timed.len();
    let mut res = vec![0f64; (num_updates * mon.relevant_ixs.len()) as usize];
    *len_out = (num_updates * mon.relevant_ixs.len()) as c_uint;

    let output_copy_res =
        updates
            .timed
            .iter()
            .enumerate()
            .for_each(|(ix, update)| {
                let (_, values) = update;
                let output: Vec<f64> = values
                    .iter()
                    .filter(|(sr, _v)| mon.relevant_ixs.contains(sr))
                    .map(|(_sr, v)| {
                        if let Value::Float(f) = v {
                            f.into_inner()
                        } else {
                            0f64
                        }
                    })
                    .collect();
                //env.set_double_array_region(res, (mon.relevant_ixs.len() * ix) as i32, &output)
                for (pos, e) in output.iter().enumerate() {
                    res[mon.relevant_ixs.len() * ix + pos] = *e
                }
            });
    //debug_assert!(output_copy_res.is_ok());

    *len_out = res.len() as c_uint;
    let ptr = res.as_mut_ptr();
    // prevent deallocation in Rust.
    // The array is still there but no Rust object feels responsible.
    // We only have ptr/len now to reach it.
    mem::forget(res);
    return ptr;
}

#[no_mangle]
/// This is intended for the C code to call for deallocating the
/// Rust-allocated i32 array.
pub unsafe extern "C" fn deallocate_rust_buffer(ptr: *mut f64, len: c_uint) {
    let len = len as usize;
    drop(Vec::from_raw_parts(ptr, len, len));
}