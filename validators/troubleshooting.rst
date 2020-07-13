Troubleshooting
---------------

Ping us on our `Discord #validators channel <https://discord.com/invite/Q38s3Vh>`_ if you need any help or see an issue. Please capture your logs (by setting ``CL_LOG_JSON_PATH: /var/logs/casperlabs`` or any other directory), zip share those with us. You can use ``jq`` to parse the json logs. If you hit an issue:

- Check and make sure that the execution engine is running as the same user as node. There is no need to run under sudo.
- Check the paths to your keys.
- Check that you have cleared out your data directory before starting the engine and node with

.. code:: None

    ./casperlabs  -global_state and sqlite.db


Feedback
~~~~~~~~

Share your feedback and suggestions using the link `here <Share your feedback and suggestions using the link here>`_.

