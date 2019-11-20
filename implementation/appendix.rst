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

      -  ``purse_id_ptr: i32``: pointer to position in wasm memory where to write the
         created ``PurseId``
      -  ``purse_id_size: i32``: allocated size for the ``PurseId``

   -  Return:

      -  ``i32``: status code for generating the purse, where 0 represents success
         and non-zero represents failure

   -  Behavior:

      -  This function uses the mint contract to create a new, empty purse. If the
         call is successful then the ``PurseId`` (in serialized form) is written to
         the indicated place in wasm memory. It is up to the caller to ensure at
         least ``purse_id_size`` bytes are allocated at ``purse_id_ptr``, otherwise
         data corruption may occur. This function causes a ``Trap`` if
         ``purse_id_size`` is not equal to 38.

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
         ``PurseId`` to transfer from
      -  ``source_size: i32``: size of the source ``PurseId`` (in bytes)
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
         source is a serialized ``PurseId``, which is equivalent to a serialized
         ``URef``. The target is a serialized ``PublicKey`` (i.e. 36 bytes where the
         first 4 bytes are the number ``32`` in little endian encoding, and the
         remaining 32-bytes are the public key). The amount must be a serialized
         512-bit unsigned integer. This function causes a ``Trap`` if the source
         cannot be de-serialized as a ``PurseId``, or the target cannot be
         de-serialized as a ``PublicKey`` or the amount cannot be de-serialized into
         a ``U512``. The return value indicated what occurred, where 0 means a
         successful transfer to an existing account, 1 means a successful transfer
         to a new account, and 2 means the transfer failed (this could be because
         the source purse had insufficient tokens or because there was not valid
         access to the source purse).

-  ``transfer_from_purse_to_purse``

   -  Arguments:

      -  ``source_ptr: i32``: pointer in wasm memory to bytes representing the source
         ``PurseId`` to transfer from
      -  ``source_size: i32``: size of the source ``PurseId`` (in bytes)
      -  ``target_ptr: i32``: pointer in wasm memory to bytes representing the target
         ``PurseId`` to transfer to
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
         source is a serialized ``PurseId``, which is equivalent to a serialized
         ``URef``. The target is also a serialized ``PurseId``. The amount must be a
         serialized 512-bit unsigned integer. This function causes a ``Trap`` if the
         source or target cannot be de-serialized as a ``PurseId`` or the amount
         cannot be de-serialized into a ``U512``. The return value indicated what
         occurred, where 0 means a successful transfer, 1 means the transfer
         failed (this could be because the source purse had insufficient tokens or
         because there was not valid access to the source purse or target purse).

-  ``get_balance``

   -  Arguments:

      -  ``purse_id_ptr: i32``: pointer in wasm memory to the bytes representing the
         ``PurseId`` of the purse to get the balance of
      -  ``purse_id_size: i32``: size of the ``PurseId`` (in bytes

   -  Return:

      -  ``i32``: size of the result (in bytes)

   -  Behavior:

      -  This function uses the mint contract’s balance function to get the balance
         of the specified ``PurseId``. It causes a ``Trap`` if the bytes in wasm memory
         from ``purse_id_ptr`` to ``purse_id_ptr + purse_id_size`` cannot be
         de-serialized as a ``PurseId``. The return value is the size of the result
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
Merkle trie. The definition of this format is as follows:

Basic data types
~~~~~~~~~~~~~~~~

Numbers
^^^^^^^

-  Unsigned integers are represented in the typical binary format, with little
   endian byte order
-  Signed integers are represented in the typical two’s complement binary format,
   with little endian byte order
-  8-bit, 32-bit, 64-bit, 128-bit, 256-bit and 512-bit numbers are supported
-  Floating point numbers are not supported

Strings
^^^^^^^

-  A string is represented by its length (in bytes, **not** characters – note
   that these could be different for UTF8 strings using non-ASCII characters)
   followed by its UTF8 encoding
-  The length is always a 32-bit unsigned integer
-  If the first 4 bytes encode the number ``n`` (as per the Numbers section
   above), then there must be exactly ``n`` bytes which follow which make up the
   data for the string (this is a formatting error otherwise)
-  If the data for the string cannot correctly be interpreted as UTF8 characters
   then this is a formatting error
-  There is no representation for a single character; if this is needed then use
   a 1 character long string to encode it
-  Note that a String is considered a basic data type as opposed to a collection
   of characters since there is no encoding for a character alone

Unit
^^^^

-  The unit data type (also sometimes referred to as the empty tuple) is
   represented as an empty byte array

Collections
~~~~~~~~~~~

As a general rule of thumb, a collection is represented as its length (the
number of items in that collection) followed by the ABI-encoded form of those
items.

Option
^^^^^^

-  ``None`` is represented by the unsigned, 8-bit number 0
-  ``Some`` is represented by the unsigned 8-bit number 1, followed by the bytes
   encoding the value the Option holds
-  It is an error for the first byte of a byte array representing an Option to be
   anything other than 0 or 1
-  Note this definition is recursive on purpose; if it is possible to
   encode/decode some type ``T`` then it is possible to encode/decode ``Option<T>``.

Either
^^^^^^

This data type distinguishes successful and error cases.

-  The first byte defines success or error:

   -  0 = ``Left`` ( in Rust it’s\ ``Err``)
   -  1 = ``Right`` ( in Rust it’s\ ``Ok``)

-  The subsequent bytes encode the value the Either holds
-  It is an error if the first byte is anything other than 0 or 1

Vector/List/Array
^^^^^^^^^^^^^^^^^

-  A vector is represented by its length (in number of elements, **not** bytes)
   followed by the elements encoded via this ABI
-  The length is always a 32-bit unsigned integer
-  If the first 4 bytes encode the number ``n`` (as per the Numbers section
   above), then there must be exactly ``n`` distinct byte arrays (concatenated
   together) which follow
-  Note that there is no delimiter between elements; it is assumed that the
   number of bytes needed for each element can be deduced from the type of
   elements stored in the vector (e.g. a vector of 32-bit signed integers would
   have each element take 4 bytes, and vector of strings would have each element
   describe its length as per the Strings section above)
-  Similar to ``Option``, this definition is recursive in the sense that if ``T`` can
   be encoded/decoded, then so can ``Vec<T>``, however only certain concrete types
   are implemented in the reference implementation for efficiency reasons
   (though this may change in the future)
-  Note that even though in Rust the length of an array is statically known
   (similarly for Vectors in dependently typed languages like Idris) we still
   include the length in the encoding because this is a feature relatively unique
   to Rust and the ABI should be language agnostic. If the length represented by
   the first 4 bytes does not match the statically known length of the array then
   a formatting error is returned

Tuple
^^^^^

-  Since a tuple is a known, fixed length, the length is not included in the
   encoding
-  A tuple is simply the concatenation of the encoding of each of its elements
-  As with Vector, there is no delimiter between elements because it is assumed
   that the number of bytes to be used can be determined based on the type of the
   element

Map
^^^

-  A map is considered to be a list of (key, value) tuples and encoded as such
   (i.e. the first 4 bytes are the number of keys in the map encoded as a 32-bit
   unsigned integer, then the data follows as a the concatenation of the
   encodings of all the key-value pairs)
-  The underlying data structure must be ordered, such that serialization is
   deterministic.

Set
^^^

-  A set is encoded as if it were a vector
-  Similar to Map, the underlying data structure must be ordered, such that
   serialization is deterministic.

Structs/Enums/Classes
^^^^^^^^^^^^^^^^^^^^^

The ABI does not support arbitrary named structures with named fields. If this
is required then the native instance will need to be represented as a tuple
containing the same data. However, because of their special importance in the
global state, some structs are supported in the ABI and the form of their
encoding could be applied to other structs/enums.

Key (the enum used as keys in the global state key-value store)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

-  The first byte determines which variant of Key is being used

   -  0 = Account
   -  1 = Hash
   -  2 = URef
   -  3 = Local

-  The remaining bytes encode the data for the Key and are different depending on
   the variant

   -  Account: 4 bytes representing the 32-bit unsigned number 20; followed by 20
      bytes which represent the account address
   -  Hash/URef: 4 bytes representing the 32-bit unsigned number 32; followed by
      32 bytes which represent the hash or uref identifier

-  If the data does not follow these definitions (e.g. the first byte is a
   number different from 0, 1, or 2; or the account “data length” is anything
   other than 20) then a formatting error is raised
-  Note that even though the length of the data is statically known we still
   include it in the encoding for consistency with the Collections ABI
   definitions

Account (the data structure which holds information relevant to on-dag accounts)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

-  This is serialized identically to the tuple ``([u8; 32], u64, Map<String, Key>)``,
   or more explicitly the concatenation of:

   -  32 bytes representing the account public key
   -  8 bytes, representing the 64-bit unsigned integer for the nonce
   -  4 bytes giving the number of keys in the known_urefs map
   -  the encoding for the data in the map

Value (the enum used as values in the global state key-value store)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

-  The first byte determines which variant of Value is being used

   -  0 = Int32
   -  1 = ByteArray
   -  2 = ListInt32
   -  3 = String
   -  4 = Account
   -  5 = Contract
   -  6 = NamedKey
   -  7 = ListString

-  This is followed by the encoded data for the Value, which depends on the
   variant being used. The data types are listed below; refer to other sections
   of this document for how they should be encoded

   -  Int32 = 32-bit signed integer
   -  ByteArray = Vector of 8-bit unsigned integers
   -  ListInt32 = Vector of 32-bit signed integers
   -  String = String
   -  ListString = Vector of Strings
   -  NamedKey = ``(String, Key)`` tuple
   -  Account = Account
   -  Contract = (Vector of 8-bit unsigned integers, ``Map<String, Key>``) tuple

-  It is an error if the data does not conform to these definitions (e.g. the
   first byte is anything other than 0 - 7)

Reference implementation
------------------------

A Rust reference implementation for those implementing this spec in another
language can be found here:

-  `bytesrepr.rs <https://github.com/CasperLabs/CasperLabs/blob/d542ea702c9d30f2e329fe65c8e958a6d54b9cae/execution-engine/contract-ffi/src/bytesrepr.rs>`__
-  `value.rs <https://github.com/CasperLabs/CasperLabs/blob/d542ea702c9d30f2e329fe65c8e958a6d54b9cae/execution-engine/contract-ffi/src/value/mod.rs>`__
-  `account.rs <https://github.com/CasperLabs/CasperLabs/blob/d542ea702c9d30f2e329fe65c8e958a6d54b9cae/execution-engine/contract-ffi/src/value/account.rs>`__
-  `contract.rs <https://github.com/CasperLabs/CasperLabs/blob/d542ea702c9d30f2e329fe65c8e958a6d54b9cae/execution-engine/contract-ffi/src/value/contract.rs>`__
-  `uint.rs <https://github.com/CasperLabs/CasperLabs/blob/d542ea702c9d30f2e329fe65c8e958a6d54b9cae/execution-engine/contract-ffi/src/value/uint.rs>`__
