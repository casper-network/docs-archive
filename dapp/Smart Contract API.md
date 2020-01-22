## **The smart contract API**

This module is supposed to be a wrapper around a separate Rust process for smart contracts execution.

You can use this documentation to access our CLContract API endpoints, and get information about CLContract types and how to build your own contracts.

We have language bindings in Shell, Rust! You can view code examples in the dark area to the right, and you can switch the programming language of the examples with the tabs in the top right.

<!--This example API documentation page was created with [Slate](https://github.com/lord/slate). Feel free to edit it and use it as a base for your own API's documentation.-->

## Authentication

> To authorize, use this code:

```ruby
require 'CLContract'

api = CLContract::APIClient.authorize!('casper')
```

```python
import CLContract

api = CLContract.authorize('casper')
```

```shell
# With shell, you can just pass the correct header with each request
curl "api_endpoint_here"
  -H "Authorization: casper"
```

```javascript
const CLContract = require('CLContract');

let api = CLContract.authorize('casper');
```

> Make sure to replace `casper` with your API key.

CLContract uses API keys to allow access to the API. You can register a new CLContract API key at our [developer portal](http://example.com/developers).

CLContract expects for the API key to be included in all API requests to the server in a header that looks like the following:

`Authorization: casper`

<aside class="notice">
You must replace <code>peaceforceandjoy</code> with your personal API key.
</aside>



## Get All CLContracts

```ruby
require 'casper'

api = Casper::APIClient.authorize!('casper')
api.caspers.get
```

```python
import clsmartcontract

api = clsmartcontract.authorize('casper')
api.caspers.get()
```

```shell
curl "http://example.com/api/caspers"
  -H "Authorization: casper"
```

```javascript
const casper = require('casper');

let api = casper.authorize('casper');
let caspers = api.caspers.get();
```

> The above command returns JSON structured like this:

```json
[
  {
    "id": 1,
    "name": "Min",
    "type": "awesome",
    "texture": 6,
    "value": 7
  },
  {
    "id": 2,
    "name": "Max",
    "type": "golden",
    "texture": 10,
    "value": 11
  }
]
```

This endpoint retrieves all CLContracts.

### HTTP Request

`GET http://example.com/api/CLContracts`

### Query Parameters

Parameter | Default | Description
--------- | ------- | -----------
include_CLContracts | false | If set to true, the result will also include CLContracts. 
available | true | If set to false, the result will include CLContracts that have already been adopted. 

<aside class="success">
Remember — a happy dApp developer is an authenticated dApp developer!
</aside>

## Get a Specific CLContract

```ruby
require 'casper'

api = Casper::APIClient.authorize!('casper')
api.caspers.get(2)
```

```python
import casper

api = casper.authorize('casper')
api.caspers.get(2)
```

```shell
curl "http://example.com/api/caspers/2"
  -H "Authorization: casper"
```

```javascript
const casper = require('casper');

let api = casper.authorize('casper');
let max = api.caspers.get(2);
```

> The above command returns JSON structured like this:

```json
{
  "id": 2,
  "name": "Max",
  "location": "secret",
  "type": 8,
  "value": 11
}
```

This endpoint retrieves a specific contract.

<aside class="warning">Inside HTML code blocks like this one, you can't use Markdown, so use <code>&lt;code&gt;</code> blocks to denote code.</aside>
### HTTP Request

`GET http://example.com/CLContracts/<ID>`

### URL Parameters

Parameter | Description
--------- | -----------
ID | The ID of the contract to retrieve 

<!--## Delete a Specific CLContract-->

<!--```ruby-->
<!--require 'casper'-->

<!--api = Casper::APIClient.authorize!('casper')-->
<!--api.caspers.delete(2)-->
<!--```-->

<!--```python-->
<!--import casper-->

<!--api = casper.authorize('casper')-->
<!--api.caspers.delete(2)-->
<!--```-->

<!--```shell-->
<!--curl "http://example.com/api/caspers/2"-->
<!--  -X DELETE-->
<!--  -H "Authorization: casper"-->
<!--```-->

<!--```javascript-->
<!--const casper = require('casper');-->

<!--let api = casper.authorize('casper');-->
<!--let max = api.caspers.delete(2);-->
<!--```-->

<!--> The above command returns JSON structured like this:-->

<!--```json-->
<!--{-->
<!--  "id": 2,-->
<!--  "deleted" : ":("-->
<!--}-->
<!--```-->

<!--This endpoint deletes a specific contract.-->

<!--### HTTP Request-->

<!--`DELETE http://example.com/CLContracts/<ID>`-->

<!--### URL Parameters-->

<!--Parameter | Description-->
<!----------- | ------------->
<!--ID | The ID of the contract to delete -->
