C# SDK (NetCasperSDK)
=====================

The `C# SDK <https://github.com/make-software/casper-net-sdk>`_ allows developers to interact with the Casper Network using C#. This page covers different examples of using the SDK.

Build
^^^^^
To build this library, install .NET 5.0 or higher and build:

.. code-block:: bash

    dotnet build --configuration Release

Tests
^^^^^
To run the tests, use this command:

.. code-block:: bash

    dotnet test --settings NetCasperTest/test.runsettings

It's usually an excellent way to understand how a library works by looking at its test. Thus, I encourage you to take a look at the ``NetCasperTest`` directory. 

Usage Examples
^^^^^^^^^^^^^^
Look into the `casper-integrations GitHub repository <https://github.com/davidatwhiletrue/casper-integrations/tree/hackaton-netcaspersdk>`_  to find a list of examples of usage of NetCasperSDK like:

* Retrieve account info and balance
* Get deploys, blocks, block transfers, state root hash, era info
* Get node status, node peers, node metrics, auction info, 
* Send a transfer
* Listen to SSE events

For key management instructions with this SDK, check this `document <https://hackmd.io/@K48d9TN9T2q7ERX4H27ysw/HkvV-MMBt>`_.

There are also available C# versions of the following tutorials:

* `C# counter <https://hackmd.io/@K48d9TN9T2q7ERX4H27ysw/SJBnPCdVt>`_ tutorial
* `C# key-value storage <https://hackmd.io/@K48d9TN9T2q7ERX4H27ysw/HyX8i0WBt>`_ tutorial

NOTE: Examples can be added to this site after the hackathon.

