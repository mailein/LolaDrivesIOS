use core::f64;
use std::os::raw::{c_char};
use std::ffi::{CString, CStr};

use core::time::Duration;
use std::vec;
use ordered_float::NotNan;
use rtlola_frontend::mir::StreamReference;
use rtlola_frontend::RtLolaMir;
use rtlola_interpreter::{Config, EvalConfig, Monitor, TimeFormat, TimeRepresentation, Value};
use rtlola_parser::ParserConfig;

static mut MONITOR: Option<Monitor> = None;
static mut IR: Option<RtLolaMir> = None;
static RELEVANT_OUTPUTS: [&str; 19] = [
    "d",
    "d_u",
    "d_r",
    "d_m",
    "t_u",
    "t_r",
    "t_m",
    "u_avg_v",
    "r_avg_v",
    "m_avg_v",
    "u_va_pct",
    "r_va_pct",
    "m_va_pct",
    "u_rpa",
    "r_rpa",
    "m_rpa",
    "nox_per_kilometer",
    "is_valid_test_num",
    "not_rde_test_num",
];
static mut RELEVANT_OUTPUT_IX: [usize; 19] =
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

static NUM_OUTPUTS: usize = 19;

#[no_mangle]
pub extern fn rust_greeting(to: *const c_char) -> *mut c_char {
    let c_str = unsafe { CStr::from_ptr(to) };
    let recipient = match c_str.to_str() {
        Err(_) => "there",
        Ok(string) => string,
    };

    CString::new("Hello ".to_owned() + recipient).unwrap().into_raw()
}

#[no_mangle]
pub extern fn rust_greeting_free(s: *mut c_char) {
    unsafe {
        if s.is_null() { return }
        CString::from_raw(s)
    };
}

#[no_mangle]
pub extern fn rust_add(a: i16, b:i16) -> i16 {
    a+b
}

#[no_mangle]
pub unsafe extern fn rust_initmonitor(s: *mut c_char)-> *mut c_char{
    let spec_file = unsafe {
        if s.is_null() { panic!() }
        CString::from_raw(s)
    };

    let cfg = ParserConfig::for_string(String::from(spec_file.to_str().unwrap()));
    let mir = rtlola_frontend::parse(cfg).unwrap();
    let indices: Vec<usize> = RELEVANT_OUTPUTS
        .iter()
        .map(|name| {
            let r = mir
                .outputs
                .iter()
                .find(|o| &o.name == *name)
                .expect("ir does not contain required output stream")
                .reference;
            if let StreamReference::Out(r) = r {
                r
            } else {
                panic!("output stream has input stream reference")
            }
        })
        .collect();
    for i in 0..RELEVANT_OUTPUT_IX.len() {
        // should prob be a mem copy of sorts.
        RELEVANT_OUTPUT_IX[i] = indices[i];
    }
    assert_eq!(NUM_OUTPUTS, RELEVANT_OUTPUTS.len());
    IR = Some(mir.clone());
    let ecfg = EvalConfig::api(TimeRepresentation::Relative(TimeFormat::HumanTime));
    MONITOR = Some(Config::new_api(ecfg, mir).into_monitor().unwrap());

    //Just to match the output-type, will remove this later
    CString::new("Worked ".to_owned()).unwrap().into_raw()
    //----
}

#[no_mangle]
pub unsafe extern fn rust_sendevent(inputs: *mut f64) -> *mut f64{
    // //jdouble = f64 (seems to work)
    let num_values = IR.as_ref().unwrap().inputs.len() + 1;
    let mut event = vec![0.0; num_values];
    event.copy_from_slice(unsafe { std::slice::from_raw_parts_mut(inputs, num_values)});
    
    //Mei: should I and how to check if the copy above works?
    // let copy_res = ???
    // debug_assert!(copy_res.is_ok());
    // if copy_res.is_err() {
    //     let res = env.new_double_array(0).unwrap();
    //     return res;
    // }

    let (time, input) = event.split_last().unwrap();
    let input: Vec<Value> = input
        .into_iter()
        .map(|f| Value::Float(NotNan::new(*f).unwrap()))
        .collect();
    let updates = MONITOR
        .as_mut()
        .unwrap()
        .accept_event(input, Duration::new(time.floor() as u64, 0));

    let num_updates = updates.timed.len();
    let res = vec![0.0; num_updates * NUM_OUTPUTS];
    //Mei: what is the type of output_copy_res???
    let output_copy_res = updates
        .timed
        .iter()
        .enumerate()
        .map(|(ix, update)| {
            let (_, values) = update;
            let output: Vec<f64> = values
                .iter()
                .filter_map(|(sr, v)| {
                    if RELEVANT_OUTPUT_IX.contains(sr) {
                        Some(v)
                    } else {
                        None
                    }
                })
                .map(|v| {
                    if let Value::Float(f) = v {
                        f.into_inner() as f64
                    } else {
                        0.0 as f64
                    }
                })
                .collect();
            res[NUM_OUTPUTS * ix..].copy_from_slice(&output);
        })
        .collect();
    // debug_assert!(output_copy_res.is_ok());
    res.as_mut_ptr()
}