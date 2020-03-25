.. _appendix-head:

Appendix
========

.. _appendix-a:

A - List of possible function imports
-------------------------------------

The following functions can be imported into a wasm module which is meant to be
used as a contract on the CasperLabs system. These functions give a contract
access to features specific to the CasperLabs platform that are not supported by
general wasm (e.g. accessing the global state, creating new ``URef``\ s). Note that
these are defined and automatically imported if the `CasperLabs rust
library <https://crates.io/crates/casperlabs-contract-ffi>`__ is used to develop
the contract; these functions should only be used directly by those writing
libraries to support developing contracts for CasperLabs in other programming
languages.

Note: anywhere serialization is referenced, the custom CasperLabs serialization
format is used. See :ref:`Appendix B <appendix-b>` for details.

-  ``read_value``

   -  Arguments:

      -  ``key_ptr: i32``: pointer (offset in wasm linear memory) to serialized form
         of the key to read.
      -  ``key_size: i32``: size of the serialized key (in bytes)

   -  Return:

      -  ``i32``: size of the serialized data read from the global state at the given
         key

   -  Behavior:

      -  The bytes in the span of wasm memory from ``key_ptr`` to
         ``key_ptr + key_size`` must correspond to a valid global state key,
         otherwise the function will fail. If the key is de-serialized
         successfully, then the result of the read is serialized and buffered in
         the runtime. This result can be obtained via the ``get_read`` function.

-  ``read_value_local``

   -  Arguments:

      -  ``key_ptr: i32``: pointer to bytes representing the user-defined key
      -  ``key_size: i32``: size of the key (in bytes)

   -  Return

      -  ``i32``: size of the serialized data read from the global state read from
         the constructed local key

   -  Behavior:

      -  The bytes in wasm memory from offset ``key_ptr`` to ``key_ptr + key_size``
         will be used together with the current context’s seed to form a local key.
         The value at that local key is read from the global state, serialized and
         buffered in the runtime. This result can be obtained via the ``get_read``
         function.

-  ``get_read``

   -  Arguments:

      -  ``pointer: i32``: pointer to position in wasm memory where the result of a
         read will be written

   -  Return:

      -  None

   -  Behavior:

      -  This function copies the contents of the current runtime buffer into the
         wasm memory, beginning at the provided offset. It is intended that this
         function be called after a call to ``read_value`` or ``read_value_local``. It
         is up to the caller to ensure that the proper amount of memory is
         allocated for this write, otherwise data corruption in the wasm memory may
         occur due to this call overwriting some bytes unintentionally. The size of
         the data which will be written is returned from the ``read_value`` and
         ``read_value_local`` functions. The bytes which are written are serialized
         of type ``Option<Value>``, and will need to be interpreted as such.

-  ``write``

   -  Arguments:

      -  ``key_ptr: i32``: pointer to bytes representing the key to write to
      -  ``key_size: i32``: size of the key (in bytes)
      -  ``value_ptr: i32``: pointer to bytes representing the value to write at the
         key
      -  ``value_size: i32``: size of the value (in bytes)

   -  Return:

      -  None

   -  Behavior:

      -  This function writes the provided value (read via de-serializing the bytes
         in wasm memory from offset ``value_ptr`` to ``value_ptr + value_size``) under
         the provided key (read via de-serializing the bytes in wasm memory from
         offset ``key_ptr`` to ``key_ptr + key_size``) in the global state. This
         function will cause a ``Trap`` if the key or value fail to de-serialize or
         if writing to that key is not permitted.

-  ``write_local``

   -  Arguments:

      -  ``key_ptr: i32``: pointer to bytes representing the user-defined key to
         write to
      -  ``key_size: i32``: size of the key (in bytes)
      -  ``value_ptr: i32``: pointer to bytes representing the value to write at the
         key
      -  ``value_size: i32``: size of the value (in bytes)

   -  Return:

      -  None

   -  Behavior:

      -  The bytes in wasm memory from offset ``key_ptr`` to ``key_ptr + key_size``
         will be used together with the current context’s seed to form a local key.
         This function writes the provided value (read via de-serializing the bytes
         in wasm memory from offset ``value_ptr`` to ``value_ptr + value_size``) under
         that local key in the global state. This function will cause a ``Trap`` if
         the value fails to de-serialize.

-  ``add``

   -  Arguments:

      -  ``key_ptr: i32``: pointer to bytes representing the key to write to
      -  ``key_size: i32``: size of the key (in bytes)
      -  ``value_ptr: i32``: pointer to bytes representing the value to write at the
         key
      -  ``value_size: i32``: size of the value (in bytes)

   -  Return:

      -  None

   -  Behavior:

      -  This function adds the provided value (read via de-serializing the bytes
         in wasm memory from offset ``value_ptr`` to ``value_ptr + value_size``) to the
         current value under the provided key (read via de-serializing the bytes in
         wasm memory from offset ``key_ptr`` to ``key_ptr + key_size``) in the global
         state. This function will cause a ``Trap`` if the key or value fail to
         de-serialize or if adding to that key is not permitted, or no value
         presently exists at that key.

-  ``new_uref``

   -  Arguments:

      -  ``key_ptr: i32``: pointer to the offset in wasm memory where the new ``URef``
         will be written
      -  ``value_ptr: i32``: pointer to bytes representing the value to write under
         the new ``URef``
      -  ``value_size: i32``: size of the value (in bytes)

   -  Return:

      -  None

   -  Behavior:

      -  This function causes the runtime to generate a new ``URef``, with the
         provided value stored under it in the global state. The new ``URef`` is
         written (in serialized form) to the wasm linear memory starting from the
         ``key_ptr`` offset. Note that data corruption is possible if not enough
         memory is allocated for the ``URef`` at ``key_ptr``. This function will cause
         a ``Trap`` if the bytes in wasm memory from offset ``value_ptr`` to
         ``value_ptr + value_size`` cannot be de-serialized into a ``Value``.

-  ``serialize_function``

   -  Arguments:

      -  ``name_ptr: i32``: pointer (offset in wasm linear memory) to serialized form
         of the name of the function (in the current wasm module).
      -  ``name_size: i32``: size of the serialized name (in bytes)

   -  Return:

      -  ``i32``: size of the serialized wasm bytes

   -  Behavior:

      -  This function extracts one function (closed under calls to other
         functions and imports) into a separate wasm module and serializes the
         result. The return value is the size of the serialized form of this new
         wasm module. During the extraction, the named function is renamed to
         “call”, so that it will be the entry point into the module if it is used
         as a contract. The purpose of this function is to allow creating new
         contracts to store on-chain. This function will cause a ``Trap`` if the name
         fails to de-serialize or if the name does not correspond to a function in
         the current wasm module. The resulting module can be obtained from the
         runtime via ``get_function``.

-  ``get_function``

   -  Arguments:

      -  ``dest_ptr: i32``: pointer to position in wasm memory where the result of a
         ``serialize_function`` call will be written

   -  Return:

      -  None

   -  Behavior:

      -  This function copies the contents of the current runtime buffer into the
         wasm memory, beginning at the provided offset. It is intended that this
         function be called after a call to ``get_function``. It is up to the caller
         to ensure that the proper amount of memory is allocated for this write,
         otherwise data corruption in the wasm memory may occur due to this call
         overwriting some bytes unintentionally. The size of the data which will be
         written is returned from the ``get_function`` call. The bytes which are
         written are the binary representation of the resulting wasm module.

-  ``store_function``

   -  Arguments:

      -  ``name_ptr: i32``: pointer (offset in wasm linear memory) to serialized form
         of the name of the function (in the current wasm module).
      -  ``name_size: i32``: size of the serialized name (in bytes)
      -  ``named_keys_ptr: i32``: pointer to bytes representing the set of named keys
         for the contract when it is stored in the global state
      -  ``named_keys_size: i32``: size of the named keys (in bytes)
      -  ``hash_ptr: i32``: the pointer in wasm memory where the hash key that the
         contract is stored under will be written (acts as the return value for
         this function)

   -  Return:

      -  None

   -  Behavior:

      -  This function stores a contract in the global state. It first extracts the
         named function from the current wasm module (as described in
         ``serialize_function``), then creates the contract object (including the
         provided named keys), generates the hash key, and writes the contract
         under that key. The Hash key is serialized and written into the wasm
         memory at the ``hash_ptr`` offset. This function will cause a ``Trap`` if the
         name cannot be de-serialized, or the name does not correspond to a
         function in the current wasm module, or the bytes for the named keys
         cannot be de-serialized as type ``BTreeMap<String, Key>``.

-  ``serialize_known_urefs``

   -  Arguments:

      -  None

   -  Return:

      -  ``i32``: size of serialized result (in bytes)

   -  Behavior:

      -  This function serializes the named keys of the current context (account
         or contract) and copies them to the runtime buffer. The result can be
         obtained from the buffer by calling ``list_known_urefs``.

-  ``list_known_urefs``

   -  Arguments:

      -  ``dest_ptr: i32``: pointer (offset in wasm memory) to the location where the
         result from ``serialize_known_urefs`` should be written

   -  Return:

      -  None

   -  Behavior:

      -  This function copies the contents of the current runtime buffer into the
         wasm memory, beginning at the provided offset. It is intended that this
         function be called after a call to ``serialize_known_urefs``. It is up to
         the caller to ensure that the proper amount of memory is allocated for
         this write, otherwise data corruption in the wasm memory may occur due to
         this call overwriting some bytes unintentionally. The size of the data
         which will be written is returned from the ``serialize_known_urefs`` call.
         The bytes which are written are the serialized form of type
         ``BTReeMap<String, Key>`` and should be interpreted as such.

-  ``load_arg``

   -  Arguments:

      -  ``i: i32``: 0-based index of the argument to load

   -  Return:

      -  ``i32``: size of result (in bytes)

   -  Behavior:

      -  This function copies the ``i``-th argument provided to the current call into
         the host buffer. The result can be obtained by calling ``get_arg``. This
         function will cause a ``Trap`` if ``i`` is out of range (e.g. if three
         arguments were provided ``i > 2`` would be invalid).

-  ``get_arg``

   -  Arguments:

      -  ``dest_ptr: i32``: pointer (offset in wasm memory) to the location where the
         result from ``load_arg`` should be written

   -  Return:

      -  None

   -  Behavior:

      -  This function copies the contents of the current runtime buffer into the
         wasm memory, beginning at the provided offset. It is intended that this
         function be called after a call to ``load_arg``. It is up to the caller to
         ensure that the proper amount of memory is allocated for this write,
         otherwise data corruption in the wasm memory may occur due to this call
         overwriting some bytes unintentionally. The size of the data which will be
         written is returned from the ``load_arg`` call. The bytes which are written
         are the those corresponding to the provided argument; it is up to the
         developer to know how to attempt to interpret those bytes.

-  ``ret``

   -  Arguments:

      -  ``value_ptr: i32``: pointer to bytes representing the value to return to the
         caller
      -  ``value_size: i32``: size of the value (in bytes)
      -  ``extra_urefs_ptr: i32``: pointer to bytes representing the additional
         ``URef``\ s to return to the caller
      -  ``extra_urefs_size: i32``: size of the extra ``URef``\ s (in bytes)

   -  Return:

      -  None

   -  Behavior:

      -  This function causes a ``Trap``, terminating the currently running module,
         but first copies the bytes from ``value_ptr`` to ``value_ptr + value_size`` to
         a buffer which is returned to the calling module (if this module was
         invoked by ``call_contract``). Additionally, the known ``URef``\ s of the
         calling context are augmented with the ``URef``\ s de-serialized from wasm
         memory offset ``extra_urefs_ptr`` to ``extra_urefs_ptr + extra_urefs_size``.
         This function will cause a ``Trap`` if the bytes at ``extra_urefs_ptr`` cannot
         be de-serialized as type ``Vec<URef>``, or if any of the extra ``URef``\ s are
         invalid in the current context.

-  ``call_contract``

   -  Arguments:

      -  ``key_ptr: i32``: pointer to bytes representing the key which points to the
         contract to call in the global state
      -  ``key_size: i32``: size of the key (in bytes)
      -  ``args_ptr: i32``: pointer to bytes representing the arguments to pass to
         the contract
      -  ``args_size: i32``: size of the arguments (in bytes)
      -  ``extra_urefs_ptr: i32``: pointer to bytes representing the additional
         ``URef``\ s to include in the context of the called contract
      -  ``extra_urefs_size: i32``: size of the extra ``URef``\ s (in bytes)

   -  Return:

      -  ``i32``: size of the return value (in bytes)

   -  Behavior:

      -  This function calls anther contract, already stored in the global state,
         with the given arguments. The new contract is run as a wasm module in its
         own instance of the wasm interpreter. Its context includes all the ``URef``\ s
         in the contract’s named keys, as well as the extra ``URef``\ s passed by the
         caller (this allows the caller to share state with the contract). If the
         called contract returns a value via ``ret`` then the size of this return
         value (in bytes) is returned as the result of this function. This function
         will cause a ``Trap`` if the key cannot be de-serialized, there is not a
         contract in the global state under the provided key, the arguments cannot
         be de-serialized as ``Vec<Vec<u8>>`` (each element of this vector represents
         the bytes for an argument to the function), or the extra ``URef``\ s cannot be
         de-serialized as ``Vec<URef>``. The return value from the called contract
         can be obtained using ``get_call_result``.

-  ``get_call_result``

   -  Arguments:

      -  ``dest_ptr: i32``: pointer (offset in wasm memory) to the location where the
         result from ``call_contract`` should be written

   -  Return:

      -  None

   -  Behavior:

      -  This function copies the contents of the current runtime buffer into the
         wasm memory, beginning at the provided offset. It is intended that this
         function be called after a call to ``call_contract``. It is up to the caller
         to ensure that the proper amount of memory is allocated for this write,
         otherwise data corruption in the wasm memory may occur due to this call
         overwriting some bytes unintentionally. The size of the data which will be
         written is returned from the ``call_contract`` call. The bytes which are
         written are those corresponding to the value returned by the called
         contract; it is up to the developer to know how to attempt to interpret
         those bytes.

-  ``get_uref``

   -  Arguments:

      -  ``name_ptr: i32``: pointer (offset in wasm linear memory) to serialized form
         of the name of the named key to get.
      -  ``name_size: i32``: size of the serialized name (in bytes)

   -  Return:

      -  ``i32``: size of the serialized key associated with that name

   -  Behavior:

      -  This function looks up a name in the named keys of the current context
         (account or contract), serializes the result and stores it in the runtime
         buffer. The result can be obtained using the ``get_arg`` function (or any
         other function that copies from the runtime buffer). The bytes that are
         copied from the buffer are of type ``Option<Key>`` and should be interpreted
         as such. The result is ``None`` if there is no key associated with the given
         name, and ``Some(key)`` otherwise. This function will cause a ``Trap`` if the
         name cannot be de-serialized as a String.

-  ``has_uref``

   -  Arguments:

      -  ``name_ptr: i32``: pointer (offset in wasm linear memory) to serialized form
         of the name of the named key to get.
      -  ``name_size: i32``: size of the serialized name (in bytes)

   -  Return:

      -  ``i32``: boolean value represented as a number, where 0 means ``true`` and
         non-zero means ``false``

   -  Behavior:

      -  This function checks if a name is associated with a key in the named keys
         of the current context (account or contract). The return value is 0 if the
         name is present and non-zero otherwise.

-  ``add_uref``

   -  Arguments:

      -  ``name_ptr: i32``: pointer (offset in wasm linear memory) to serialized form
         of the name of the named key to associate.
      -  ``name_size: i32``: size of the serialized name (in bytes)
      -  ``key_ptr: i32``: pointer to bytes representing the key to write to
      -  ``key_size: i32``: size of the key (in bytes)

   -  Return:

      -  None

   -  Behavior:

      -  This function associates a name with a key in the named keys of the
         current context (account or contract). It causes a ``Trap`` if the name
         cannot be de-serialized as a string, or if the key cannot be de-serialized
         as a ``Key``. Note that if the name is already associated with a key then it
         is overwritten.

-  ``remove_uref``

   -  Arguments:

      -  ``name_ptr: i32``: pointer (offset in wasm linear memory) to serialized form
         of the name of the named key to remove.
      -  ``name_size: i32``: size of the serialized name (in bytes)

   -  Return:

      -  None

   -  Behavior:

      -  This function removes a name in the named keys of the current context
         (account or contract). This function is a no-op if the name was not in the
         named keys map to begin with. It causes a ``Trap`` if the name cannot be
         de-serialized as type string.

-  ``protocol_version``

   -  Arguments:

      -  None

   -  Return:

      -  ``i64``: the protocol version

   -  Behavior:

      -  This function looks up the protocol version of the runtime.

-  ``revert``

   -  Arguments:

      -  ``status: i32``: error code of the revert

   -  Return:

      -  None

   -  Behavior:

      -  This function causes a ``Trap`` which terminates the currently running
         module. Additionally, it signals that the current entire phase of
         execution of the deploy should be terminated as well, and that the effects
         of the execution up to this point should be reverted. The error code
         provided to this function will be included in the error message of the
         deploy in the block in which it is included.

-  ``is_valid``

   -  Arguments:

      -  ``value_ptr: i32``: pointer to bytes representing the value to write under
         the new ``URef``
      -  ``value_size: i32``: size of the value (in bytes)

   -  Return:

      -  ``i32``: boolean represented as a number, where 0 means the value invalid
         and non-zero means the value was valid

   -  Behavior:

      -  This function checks if all the keys contained in the given ``Value`` are
         valid in the current context (i.e. the ``Value`` does not contain any forged
         ``URef``\ s). This function causes a ``Trap`` if the bytes in wasm memory from
         offset ``value_ptr`` to ``value_ptr + value_size`` cannot be de-serialized as
         type ``Value``.

-  ``add_associated_key``

   -  Arguments:

      -  ``public_key: i32``: pointer to the bytes in wasm memory representing the
         public key to add, presently only 32-byte public keys are supported
      -  ``weight: i32``: the weight to assign to this public key

   -  Return:

      -  ``i32``: status code for adding the key, where 0 represents success and
         non-zero represents failure

   -  Behavior:

      -  This function attempts to add the given public key as an associated key to
         the current account. Presently only 32-byte keys are supported; it is up
         to the caller to ensure that the 32-bytes starting from offset
         ``public_key`` represent the key they wish to add. Weights are internally
         represented by a ``u8``, this function will cause a ``Trap`` if the weight is
         not between 0 and 255 inclusively. The result returned is a status code
         for adding the key where 0 represents success, 1 means no more keys can be
         added to this account (only 10 keys can be added), 2 means the key is
         already associated (if you wish to change the weight of an associated key
         then used ``update_associated_key``), and 3 means permission denied (this
         could be because the function was called outside of session code or
         because the key management threshold was not met by the keys authorizing
         the deploy).

-  ``remove_associated_key``

   -  Arguments:

      -  ``public_key: i32``: pointer to the bytes in wasm memory representing the
         public key to remove, presently only 32-byte public keys are supported

   -  Return:

      -  ``i32``: status code for removing the key, where 0 represents success and
         non-zero represents failure

   -  Behavior:

      -  This function attempts to remove the given public key from the associated
         keys of the current account. Presently only 32-byte keys are supported; it
         is up to the caller to ensure that the 32-bytes starting from offset
         ``public_key`` represent the key they wish to remove. The result returned is
         a status code for adding the key where 0 represents success, 1 means the
         key was not associated to begin with, 2 means means permission denied
         (this could be because the function was called outside of session code or
         because the key management threshold was not met by the keys authorizing
         the deploy), and 3 means this key cannot be removed because otherwise it
         would be impossible to meet either the deploy or key management
         thresholds.

-  ``update_associated_key``

   -  Arguments:

      -  ``public_key: i32``: pointer to the bytes in wasm memory representing the
         public key to update, presently only 32-byte public keys are supported
      -  ``weight: i32``: the weight to assign to this public key

   -  Return:

      -  ``i32``: status code for adding the key, where 0 represents success and
         non-zero represents failure

   -  Behavior:

      -  This function attempts to update the given public key as an associated key
         to the current account. Presently only 32-byte keys are supported; it is
         up to the caller to ensure that the 32-bytes starting from offset
         ``public_key`` represent the key they wish to add. Weights are internally
         represented by a ``u8``, this function will cause a ``Trap`` if the weight is
         not between 0 and 255 inclusively. The result returned is a status code
         for adding the key where 0 represents success, 1 means the key was not
         associated to the account (to add a new key use ``add_associated_key``), 2
         means means permission denied (this could be because the function was
         called outside of session code or because the key management threshold was
         not met by the keys authorizing the deploy), and 3 means this key cannot
         be changed to the specified weight because then it would be impossible to
         meet either the deploy or key management thresholds (you may wish to try
         again with a higher weight or after lowering the action thresholds).

-  ``set_action_threshold``

   -  Arguments:

      -  ``action: i32``: index representing the action threshold to set
      -  ``threshold: i32``: new value of the threshold for performing this action

   -  Return:

      -  ``i32``: status code for the change where 0 means successful and non-zero
         means failure

   -  Behavior:

      -  This function changes the threshold to perform the specified action. The
         action index is interpreted as follows: 0 means deployment and 1 means key
         management. Thresholds are represented internally as a ``u8``, this function
         will cause a ``Trap`` if the new threshold is not between 0 and 255
         inclusively. The return value is a status code where 0 means success, 1
         means the key management threshold cannot be set lower than the deploy
         threshold, 2 means the deployment threshold cannot be set higher than the
         key management threshold, 3 means permission denied (this could be because
         the function was called outside of session code or because the key
         management threshold was not met by the keys authorizing the deploy), and
         4 means the threshold would be set higher than the total weight of
         associated keys (and therefore would be impossible to meet).

-  ``get_caller``

   -  Arguments:

      -  ``dest_ptr: i32``: pointer to position in wasm memory where to write the
         result

   -  Return:

      -  None

   -  Behavior:

      -  This function returns the public key of the account for this deploy. The
         result is always 36-bytes in length (4 bytes prefix on a 32-byte public
         key); it is up to the caller to ensure the right amount of memory is
         allocated at ``dest_ptr``, data corruption in the wasm memory could occur
         otherwise.

-  ``create_purse``

   -  Arguments:

      -  ``purse_ptr: i32``: pointer to position in wasm memory where to write the
         created ``URef``
      -  ``purse_size: i32``: allocated size for the ``URef``

   -  Return:

      -  ``i32``: status code for generating the purse, where 0 represents success
         and non-zero represents failure

   -  Behavior:

      -  This function uses the mint contract to create a new, empty purse. If the
         call is successful then the ``URef`` (in serialized form) is written to
         the indicated place in wasm memory. It is up to the caller to ensure at
         least ``purse_size`` bytes are allocated at ``purse_ptr``, otherwise
         data corruption may occur. This function causes a ``Trap`` if
         ``purse_size`` is not equal to 38.

-  ``transfer_to_account``

   -  Arguments:

      -  ``target_ptr: i32``: pointer in wasm memory to bytes representing the target
         account to transfer to
      -  ``target_size: i32``: size of the target (in bytes)
      -  ``amount_ptr: i32``: pointer in wasm memory to bytes representing the amount
         to transfer to the target account
      -  ``amount_size: i32``: size of the amount (in bytes)

   -  Return:

      -  ``i32``: status code indicating if the transfer was successful to a new or
         existing account or an error

   -  Behavior:

      -  This function uses the mint contract’s transfer function to transfer
         tokens from the current account’s main purse to the main purse of the
         target account. If the target account does not exist then it is
         automatically created, and the tokens are transferred to the main purse of
         the new account. The target is a serialized ``PublicKey`` (i.e. 36 bytes
         where the first 4 bytes are the number ``32`` in little endian encoding, and
         the remaining 32-bytes are the public key). The amount must be a
         serialized 512-bit unsigned integer. This function causes a ``Trap`` if the
         target cannot be de-serialized as a ``PublicKey`` or the amount cannot be
         de-serialized into a ``U512``. The return value indicated what occurred,
         where 0 means a successful transfer to an existing account, 1 means a
         successful transfer to a new account, and 2 means the transfer failed
         (this could be because the current account’s main purse had insufficient
         tokens or because the function was called outside of session code and so
         does not have access to the account’s main purse).

-  ``get_blocktime``

   -  Arguments:

      -  ``dest_ptr: i32``: pointer in wasm memory where to write the result

   -  Return:

      -  None

   -  Behavior:

      -  This function gets the timestamp which will be in the block this deploy is
         included in. The return value is always a 64-bit unsigned integer,
         representing the number of milliseconds since the Unix epoch. It is up to
         the caller to ensure there are 8 bytes allocated at ``dest_ptr``, otherwise
         data corruption in the wasm memory may occur.

-  ``transfer_from_purse_to_account``

   -  Arguments:

      -  ``source_ptr: i32``: pointer in wasm memory to bytes representing the source
         ``URef`` to transfer from
      -  ``source_size: i32``: size of the source ``URef`` (in bytes)
      -  ``target_ptr: i32``: pointer in wasm memory to bytes representing the target
         account to transfer to
      -  ``target_size: i32``: size of the target (in bytes)
      -  ``amount_ptr: i32``: pointer in wasm memory to bytes representing the amount
         to transfer to the target account
      -  ``amount_size: i32``: size of the amount (in bytes)

   -  Return:

      -  ``i32``: status code indicating if the transfer was successful to a new or
         existing account or an error

   -  Behavior:

      -  This function uses the mint contract’s transfer function to transfer
         tokens from the specified purse to the main purse of the target account.
         If the target account does not exist then it is automatically created, and
         the tokens are transferred to the main purse of the new account. The
         source is a serialized ``URef``.
         The target is a serialized ``PublicKey`` (i.e. 36 bytes where the
         first 4 bytes are the number ``32`` in little endian encoding, and the
         remaining 32-bytes are the public key). The amount must be a serialized
         512-bit unsigned integer. This function causes a ``Trap`` if the source
         cannot be de-serialized as a ``URef``, or the target cannot be
         de-serialized as a ``PublicKey`` or the amount cannot be de-serialized into
         a ``U512``. The return value indicated what occurred, where 0 means a
         successful transfer to an existing account, 1 means a successful transfer
         to a new account, and 2 means the transfer failed (this could be because
         the source purse had insufficient tokens or because there was not valid
         access to the source purse).

-  ``transfer_from_purse_to_purse``

   -  Arguments:

      -  ``source_ptr: i32``: pointer in wasm memory to bytes representing the source
         ``URef`` to transfer from
      -  ``source_size: i32``: size of the source ``URef`` (in bytes)
      -  ``target_ptr: i32``: pointer in wasm memory to bytes representing the target
         ``URef`` to transfer to
      -  ``target_size: i32``: size of the target (in bytes)
      -  ``amount_ptr: i32``: pointer in wasm memory to bytes representing the amount
         to transfer to the target account
      -  ``amount_size: i32``: size of the amount (in bytes)

   -  Return:

      -  ``i32``: status code, where 0 means the transfer was successful and non-zero
         means there was an error

   -  Behavior:

      -  This function uses the mint contract’s transfer function to transfer
         tokens from the specified source purse to the specified target purse. If
         the target account does not exist then it is automatically created, and
         the tokens are transferred to the main purse of the new account. The
         source is a serialized ``URef``.
         The target is also a serialized ``URef``. The amount must be a
         serialized 512-bit unsigned integer. This function causes a ``Trap`` if the
         source or target cannot be de-serialized as a ``URef`` or the amount
         cannot be de-serialized into a ``U512``. The return value indicated what
         occurred, where 0 means a successful transfer, 1 means the transfer
         failed (this could be because the source purse had insufficient tokens or
         because there was not valid access to the source purse or target purse).

-  ``get_balance``

   -  Arguments:

      -  ``purse_ptr: i32``: pointer in wasm memory to the bytes representing the
         ``URef`` of the purse to get the balance of
      -  ``purse_size: i32``: size of the ``URef`` (in bytes

   -  Return:

      -  ``i32``: size of the result (in bytes)

   -  Behavior:

      -  This function uses the mint contract’s balance function to get the balance
         of the specified purse. It causes a ``Trap`` if the bytes in wasm memory
         from ``purse_ptr`` to ``purse_ptr + purse_size`` cannot be
         de-serialized as a ``URef``. The return value is the size of the result
         in bytes. The result is copied to the host buffer and thus can be obtained
         by any function which copies the buffer into wasm memory (e.g.
         ``get_read``). The result bytes are serialized from type ``Option<U512>`` and
         should be interpreted as such.

-  ``get_phase``

   -  Arguments:

      -  ``dest_ptr: i32``: pointer to position in wasm memory to write the result

   -  Return:

      -  None

   -  Behavior:

      -  This function writes bytes representing the current phase of the deploy
         execution to the specified pointer. The size of the result is always one
         byte, it is up to the caller to ensure one byte of memory is allocated at
         ``dest_ptr``, otherwise data corruption in the wasm memory could occur. The
         one byte is interpreted as follows: 0 means a system phase (should never
         be encountered by user deploys), 1 means the payment phase, 2 means the
         session phase and 3 means the finalization phase (should never be
         encountered by user code).

.. _appendix-b:

B - Serialization format
------------------------

The CasperLabs serialization format is used to pass data between wasm and the
CasperLabs host runtime. It is also used to persist global state data in the
Merkle trie. The definition of this format is described in the
:ref:`Global State <global-state-values>` section.

A Rust reference implementation for those implementing this spec in another
language can be found here:

-  `bytesrepr.rs <https://docs.rs/casperlabs-types/0.2.0/casperlabs_types/bytesrepr/index.html>`__
-  `cl_value.rs <https://docs.rs/casperlabs-types/0.2.0/src/casperlabs_types/cl_value.rs.html>`__
-  `account.rs <https://docs.rs/casperlabs-engine-shared/0.3.0/casperlabs_engine_shared/account/struct.Account.html>`__
-  `contract.rs <https://docs.rs/casperlabs-engine-shared/0.3.0/casperlabs_engine_shared/contract/struct.Contract.html>`__
-  `uint.rs <https://docs.rs/casperlabs-types/0.2.0/src/casperlabs_types/uint.rs.html>`__
