use core::f64;
use std::os::raw::{c_char, c_uint};
use std::ffi::{CString};

mod bridge;

static mut MONITOR: Option<bridge::KotlinMonitor> = None;

//Function to initialize the Monitor we will feed with events, with the RDE-Specification
#[no_mangle]
pub unsafe extern "C" fn rust_initmonitor(
    j_recipient: *mut c_char,
    relevant_outputs: *mut c_char
) -> *mut c_char {
    let m = bridge::init(j_recipient, relevant_outputs);
    MONITOR = Some(m);

    CString::new("Worked ".to_owned()).unwrap().into_raw()
}


//Function which transmits the new Values of the current Period (1Hz) to the Monitor and returns the generated outputs to the App
//6 Float64 Input Streams (Float64) and 1 Trigger
#[no_mangle]
pub unsafe extern "C" fn rust_sendevent(
    inputs: *mut f64,
    len_in: c_uint,
    len_out: *mut c_uint
) -> *mut f64 {
    let monitor = MONITOR.as_mut().unwrap();
    let res = bridge::receive_total_event(monitor, inputs, len_out);
    res
}

#[no_mangle]
pub extern fn rust_string_free(s: *mut c_char) {
    unsafe {
        if s.is_null() { return }
        CString::from_raw(s)
    };
}
