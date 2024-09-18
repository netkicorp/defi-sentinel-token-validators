/// Module: events
module verifier::events {
    use sui::event;
    use std::string::String;

    /// Define a custom event struct
    public struct GenericEvent has copy, drop {
        message: String,
    }

    /// Function to emit the custom event with any string
    public fun emit_event(message: String) {
        let event = GenericEvent { message };
        event::emit(event);
    }
}
