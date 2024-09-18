/// Module: verifier
module verifier::token {
    use std::string::String;
    use sui::clock::Clock;
    use sui::ed25519;
    use std::debug;
    use verifier::events;

    /// Represents a signed message with its public key and signature.
    public struct SignedMessage has drop {
        /// The message being signed.
        message: vector<u8>,
        /// The public key of the signer.
        public_key: vector<u8>,
        /// The signature of the message.
        signature: vector<u8>,
    }

    /// Creates a new SignedMessage instance.
    public fun new(message: vector<u8>, public_key: vector<u8>, signature: vector<u8>): SignedMessage {
        SignedMessage { message, public_key, signature }
    }

    public fun verify_token_unfold(
        message: vector<u8>,
        public_key: vector<u8>,
        signature: vector<u8>,
        clock: &Clock,
        ctx: &mut TxContext,
    ): bool {
        debug::print(&b"Starting message verification.".to_string());
        events::emit_event(b"Starting message verification.".to_string());
        let signed_msg = new(message, public_key, signature);
        let result = verify_token(&signed_msg, clock, ctx);
        if (result) {
            debug::print(&b"Message verification succeeded.".to_string());
            events::emit_event(b"Message verification succeeded.".to_string());
        } else {
            debug::print(&b"Message verification failed.".to_string());
            events::emit_event(b"Message verification failed.".to_string());
        };

        result
    }

    /// Verifies the token by checking the signature, user address, transaction time, and signer.
    public fun verify_token(signed_msg: &SignedMessage, clock: &Clock, tx_context: &mut TxContext): bool {
        // Define constants for validation
        let valid_signer: String = b"0xeafD54E545c077ca1Bb9259fa2F90091Db96F8CC".to_string();
        let maximum_valid_time_gap: u64 = 86400000; // 24 hours in milliseconds

        // Convert the message to a string for easier manipulation
        let message = signed_msg.message.to_string();

        // Validate the signature
        if (!ed25519::ed25519_verify(&signed_msg.signature, &signed_msg.public_key, &signed_msg.message)) {
            // If the signature is invalid, return false
            debug::print(&b"Invalid signature".to_string());
            events::emit_event(b"Invalid signature".to_string());
            return false
        };

        // Validate the user address
        let signed_user_address = get_user_address(message);
        if (signed_user_address != tx_context.sender().to_string()) {
            // If the user addresses do not match, return false
            debug::print(&b"Invalid user address".to_string());
            events::emit_event(b"Invalid user address".to_string());
            return false
        };

        // Validate the transaction time
        let signed_tx_time_string = get_timestamp(message);
        let signed_tx_time_u64 = convert_hex_to_u64(std::string::into_bytes(signed_tx_time_string));
        let current_time_u64 = clock.timestamp_ms();
        let time_gap = current_time_u64 - signed_tx_time_u64;
        if (time_gap > maximum_valid_time_gap) {
            // If the transaction is older than 24 hours, return false
            debug::print(&b"Invalid timestamp".to_string());
            events::emit_event(b"Invalid timestamp".to_string());
            return false
        };

        // Validate the signer
        let signed_signer = get_signer(message);
        if (signed_signer != valid_signer) {
            // If the signer is not valid, return false
            debug::print(&b"Invalid signer".to_string());
            events::emit_event(b"Invalid signer".to_string());
            return false
        };

        // If all checks pass, return true
        return true
    }

    /// Extracts the user address from the message.
    fun get_user_address(message: String): String {
        // The user address is located at indices 375-439 in the message
        message.substring(375, 439)
    }

    /// Extracts the signer from the message.
    fun get_signer(message: String): String {
        // The signer is located at indices 321-363 in the message
        message.substring(321, 363)
    }

    /// Extracts the timestamp from the message.
    fun get_timestamp(message: String): String {
        // The timestamp is located at indices 464-474 in the message
        let timestamp_str = message.substring(464, 477);
        timestamp_str
    }

    /// Converts a hexadecimal string to a u64 integer.
    fun convert_hex_to_u64(bytes: vector<u8>): u64 {
        let mut result = 0u64;
        let len = vector::length(&bytes);
        let mut i = 0;
        while (i < len) {
            let byte = vector::borrow(&bytes, i);
            let byte_u64 = (*byte as u64);
            result = result * 10 + (byte_u64 - 48);
            i = i + 1;
        };
        result
    }
}
