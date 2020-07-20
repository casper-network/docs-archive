## CasperLabs Contract DSL

The DSL is a way to help developers avoid boilerplate code.  This boilerplate code is repetitive and well structured, 
enabling the creation of a DSL that uses macros to create this boilerplate code- which simplifies the creation and standardization of contracts.

The code will be a bit larger after the macros run and the boilerplate code is added into the contract. The macros operate like templates.  

The macros work with Contract Headers (released as part of the 0.20 release).  Contracts created prior to 0.20 will need to be upgraded to use the macros.

### Table of Contents

* Getting started with the DSL
  * Importing the macros
  * Using the macros
  * Basic syntax
* About the macros
  * casperlabs_contract
  * casperlabs_constructor
  * casperlabs_method
  * casperlabs_initiator (optional macro)
* Looking at the expanded code (Advanced)
  * Using cargo-expand
  * Optimizing the code for gas costs (TODO)
* Debugging

.. toctree::
 getting-started
 about
 advanced
 debugging
