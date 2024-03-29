# donations-dapp-soroban
Just a dApp example in order to interact with the native token (XLM) inside Soroban smart contracts

## The smart contract
The smart contract has 4 functions:
- `initialize`. The deployer sets the token that will be accepted as donations, as well as the `recipient` account
- `donate`. A donor donates in the accepted token
- `withdraw`. Anyone can trigger this function. All funds are sent to the `recipient`

## Experiment:

0. Clone the project and install dependencies (this is only if you will experiment as in step 5)
```bash
git clone 
https://github.com/esteblock/donations-dapp-soroban
cd donations-dapp-soroban
yarn
```

1. In one terminal open the stellar quickstart image and run a soroban-preview:10 docker image
```bash
bash quickstart.sh standalone
```

2. In other terminal open a terminal of the soroban-preview:10 docker container
```bash
bash run.sh
```

3. Build the contract
```bash
cd contracts
make build
```

4. Test the contract
```bash
make test
```

5. Experiment with the contract using soroban-cli and the quickstart image
Inside the soroban-preview:10 docker container run:
```bash
bash test_soroban_cli.sh 
```
This will deploy the contract inside a Standalone Soroban blockchain, will create some accounts, donate and check every account's XML balance both using the native token contract inside Soroban, as well as in the classic way!


## What's next? 1: Testing the XML native token inside soroban-sdk

Check the discussion in Discord: https://discord.com/channels/897514728459468821/1145462925109231726/1145462925109231726

In the `test.rs` file you'll find 2 tests. One is for any type of tokens, and works perfect. The second test is ment to be only for the native XML token....

When you create the XML native token inside `test.rs` you get:
```rust
fn native_asset_contract_address(e: &Env) -> Address {
    let native_asset = Asset::Native;
    let contract_id_preimage = ContractIdPreimage::Asset(native_asset);
    let bytes = Bytes::from_slice(&e, &contract_id_preimage.to_xdr().unwrap());
    let native_asset_address = Address::from_contract_id(&e.crypto().sha256(&bytes));
    native_asset_address
}

 // Set the native token address
    let native_address =native_asset_contract_address(&e);    
    let expected_address_string = "CDF3YSDVBXV3QU2QSOZ55L4IVR7UZ74HIJKXNJMN4K5MOVFM3NDBNMLY";
    let Strkey::Contract(array) = Strkey::from_string(expected_address_string).unwrap() else { panic!("Failed to convert address") };
    let contract_id = BytesN::from_array(&e, &array.0);
    let expected_asset_address = Address::from_contract_id(&contract_id);
    assert_eq!(native_address, expected_asset_address);

```

Until there everything is OK, but if you'll later want to check any user's balance.... how van we do it inside `test.rs`? I get these errors:

```rust
---- test::test stdout ----
thread 'test::test' panicked at 'HostError: Error(Storage, MissingValue)

Event log (newest first):
   0: [Diagnostic Event] topics:[error, Error(Storage, MissingValue)], data:"escalating error to panic"
   1: [Diagnostic Event] topics:[error, Error(Storage, MissingValue)], data:["contract call failed", name, []]
   2: [Diagnostic Event] topics:[fn_call, Bytes(cbbc48750debb8535093b3deaf88ac7f4cff87425576a58de2bac754acdb4616), name], data:Void
   3: [Diagnostic Event] contract:83b030d83a5d502cc001c50f8b714ce54a0ba8c6c4cda46281a060cd47134695, topics:[fn_return, token], data:Address(Contract(cbbc48750debb8535093b3deaf88ac7f4cff87425576a58de2bac754acdb4616))
   4: [Diagnostic Event] topics:[fn_call, Bytes(83b030d83a5d502cc001c50f8b714ce54a0ba8c6c4cda46281a060cd47134695), token], data:Void
   5: [Diagnostic Event] contract:83b030d83a5d502cc001c50f8b714ce54a0ba8c6c4cda46281a060cd47134695, topics:[fn_return, recipient], data:Address(Contract(06ecc85c9d15d14b787b5eafe1afa00e78f9fbd8fb8003b9bbe1735efe00f911))
   6: [Diagnostic Event] topics:[fn_call, Bytes(83b030d83a5d502cc001c50f8b714ce54a0ba8c6c4cda46281a060cd47134695), recipient], data:Void
   7: [Diagnostic Event] contract:83b030d83a5d502cc001c50f8b714ce54a0ba8c6c4cda46281a060cd47134695, topics:[fn_return, initialize], data:Void
   8: [Diagnostic Event] topics:[fn_call, Bytes(83b030d83a5d502cc001c50f8b714ce54a0ba8c6c4cda46281a060cd47134695), initialize], data:[Address(Contract(06ecc85c9d15d14b787b5eafe1afa00e78f9fbd8fb8003b9bbe1735efe00f911)), Address(Contract(cbbc48750debb8535093b3deaf88ac7f4cff87425576a58de2bac754acdb4616))]
```

## What's next? 2: Find why first donation from any accound does not works

Check the discussion in Discord: https://discord.com/channels/897514728459468821/1145688416432963705/1145688416432963705

There is something strange happening.
When the donor account tries to donate for the first time, I get:
```bash
Donor donates 5 stroops to the contract
2023-08-28T11:50:39.327476Z ERROR soroban_cli::rpc: response=GetTransactionResponse { status: "FAILED", envelope_xdr: Some("AAAAAgAAAACeY8pVwnmE8JqDzK9Q+EkYoKr+GM9nd5ydMt1w5vPOfAAPQkAAAAMdAAAAAQAAAAAAAAAAAAAAAQAAAAAAAAAYAAAAAAAAAAQAAAASAAAAAc3yrw8qFZB18IPdID6W986RYa2BTJ3RdMW0Cv0RpWMpAAAADwAAAAZkb25hdGUAAAAAABIAAAAAAAAAAJ5jylXCeYTwmoPMr1D4SRigqv4Yz2d3nJ0y3XDm8858AAAACgAAAAAAAAAAAAAAAAAAAAUAAAABAAAAAAAAAAAAAAABzfKvDyoVkHXwg90gPpb3zpFhrYFMndF0xbQK/RGlYykAAAAGZG9uYXRlAAAAAAACAAAAEgAAAAAAAAAAnmPKVcJ5hPCag8yvUPhJGKCq/hjPZ3ecnTLdcObzznwAAAAKAAAAAAAAAAAAAAAAAAAABQAAAAEAAAAAAAAAAdiysUxg/stl+yqoHL6nnQg1yvwODYUfhhElfB5bQeHCAAAACHRyYW5zZmVyAAAAAwAAABIAAAAAAAAAAJ5jylXCeYTwmoPMr1D4SRigqv4Yz2d3nJ0y3XDm8858AAAAEgAAAAHN8q8PKhWQdfCD3SA+lvfOkWGtgUyd0XTFtAr9EaVjKQAAAAoAAAAAAAAAAAAAAAAAAAAFAAAAAAAAAAEAAAAAAAAAAwAAAAYAAAABzfKvDyoVkHXwg90gPpb3zpFhrYFMndF0xbQK/RGlYykAAAAUAAAAAQAAAAAAAAAGAAAAAdiysUxg/stl+yqoHL6nnQg1yvwODYUfhhElfB5bQeHCAAAAFAAAAAEAAAAAAAAAB+PjRjqK0s+gJdYgY0E9XGm55ULUipd1wxLu00oINUONAAAAAAAAAAIAAAAAAAAAAJ5jylXCeYTwmoPMr1D4SRigqv4Yz2d3nJ0y3XDm8858AAAABgAAAAHYsrFMYP7LZfsqqBy+p50INcr8Dg2FH4YRJXweW0HhwgAAABAAAAABAAAAAgAAAA8AAAAHQmFsYW5jZQAAAAASAAAAAc3yrw8qFZB18IPdID6W986RYa2BTJ3RdMW0Cv0RpWMpAAAAAQAAAAAAI9fhAAAMAAAAAeAAAAX4AAAAAAAAASsAAAAB5vPOfAAAAEBPNszaix41MQPzt4ceL6TeSE5coHLWGtJypGaum7YmvQ2NKjzSE9IGLiOsD5gzWxOYkIuKGqqlmyhp8sBWQY4C"), result_xdr: Some("AAAAAAABnML/////AAAAAQAAAAAAAAAY/////QAAAAA="), result_meta_xdr: Some("AAAAAwAAAAAAAAACAAAAAwAAAzUAAAAAAAAAAJ5jylXCeYTwmoPMr1D4SRigqv4Yz2d3nJ0y3XDm8858AAAAF4QQFT4AAAMdAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAzUAAAAAAAAAAJ5jylXCeYTwmoPMr1D4SRigqv4Yz2d3nJ0y3XDm8858AAAAF4QQFT4AAAMdAAAAAQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAMAAAAAAAADNQAAAABk7IoOAAAAAAAAAAAAAAACAAAAAwAAAzUAAAAAAAAAAJ5jylXCeYTwmoPMr1D4SRigqv4Yz2d3nJ0y3XDm8858AAAAF4QQFT4AAAMdAAAAAQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAMAAAAAAAADNQAAAABk7IoOAAAAAAAAAAEAAAM1AAAAAAAAAACeY8pVwnmE8JqDzK9Q+EkYoKr+GM9nd5ydMt1w5vPOfAAAABeEEBZpAAADHQAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAIAAAAAAAAAAAAAAAAAAAADAAAAAAAAAzUAAAAAZOyKDgAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAA=") }
error: transaction submission failed: GetTransactionResponse {
    status: "FAILED",
    envelope_xdr: Some(
        "AAAAAgAAAACeY8pVwnmE8JqDzK9Q+EkYoKr+GM9nd5ydMt1w5vPOfAAPQkAAAAMdAAAAAQAAAAAAAAAAAAAAAQAAAAAAAAAYAAAAAAAAAAQAAAASAAAAAc3yrw8qFZB18IPdID6W986RYa2BTJ3RdMW0Cv0RpWMpAAAADwAAAAZkb25hdGUAAAAAABIAAAAAAAAAAJ5jylXCeYTwmoPMr1D4SRigqv4Yz2d3nJ0y3XDm8858AAAACgAAAAAAAAAAAAAAAAAAAAUAAAABAAAAAAAAAAAAAAABzfKvDyoVkHXwg90gPpb3zpFhrYFMndF0xbQK/RGlYykAAAAGZG9uYXRlAAAAAAACAAAAEgAAAAAAAAAAnmPKVcJ5hPCag8yvUPhJGKCq/hjPZ3ecnTLdcObzznwAAAAKAAAAAAAAAAAAAAAAAAAABQAAAAEAAAAAAAAAAdiysUxg/stl+yqoHL6nnQg1yvwODYUfhhElfB5bQeHCAAAACHRyYW5zZmVyAAAAAwAAABIAAAAAAAAAAJ5jylXCeYTwmoPMr1D4SRigqv4Yz2d3nJ0y3XDm8858AAAAEgAAAAHN8q8PKhWQdfCD3SA+lvfOkWGtgUyd0XTFtAr9EaVjKQAAAAoAAAAAAAAAAAAAAAAAAAAFAAAAAAAAAAEAAAAAAAAAAwAAAAYAAAABzfKvDyoVkHXwg90gPpb3zpFhrYFMndF0xbQK/RGlYykAAAAUAAAAAQAAAAAAAAAGAAAAAdiysUxg/stl+yqoHL6nnQg1yvwODYUfhhElfB5bQeHCAAAAFAAAAAEAAAAAAAAAB+PjRjqK0s+gJdYgY0E9XGm55ULUipd1wxLu00oINUONAAAAAAAAAAIAAAAAAAAAAJ5jylXCeYTwmoPMr1D4SRigqv4Yz2d3nJ0y3XDm8858AAAABgAAAAHYsrFMYP7LZfsqqBy+p50INcr8Dg2FH4YRJXweW0HhwgAAABAAAAABAAAAAgAAAA8AAAAHQmFsYW5jZQAAAAASAAAAAc3yrw8qFZB18IPdID6W986RYa2BTJ3RdMW0Cv0RpWMpAAAAAQAAAAAAI9fhAAAMAAAAAeAAAAX4AAAAAAAAASsAAAAB5vPOfAAAAEBPNszaix41MQPzt4ceL6TeSE5coHLWGtJypGaum7YmvQ2NKjzSE9IGLiOsD5gzWxOYkIuKGqqlmyhp8sBWQY4C",
    ),
    result_xdr: Some(
        "AAAAAAABnML/////AAAAAQAAAAAAAAAY/////QAAAAA=",
    ),
    result_meta_xdr: Some(
        "AAAAAwAAAAAAAAACAAAAAwAAAzUAAAAAAAAAAJ5jylXCeYTwmoPMr1D4SRigqv4Yz2d3nJ0y3XDm8858AAAAF4QQFT4AAAMdAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAzUAAAAAAAAAAJ5jylXCeYTwmoPMr1D4SRigqv4Yz2d3nJ0y3XDm8858AAAAF4QQFT4AAAMdAAAAAQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAMAAAAAAAADNQAAAABk7IoOAAAAAAAAAAAAAAACAAAAAwAAAzUAAAAAAAAAAJ5jylXCeYTwmoPMr1D4SRigqv4Yz2d3nJ0y3XDm8858AAAAF4QQFT4AAAMdAAAAAQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAMAAAAAAAADNQAAAABk7IoOAAAAAAAAAAEAAAM1AAAAAAAAAACeY8pVwnmE8JqDzK9Q+EkYoKr+GM9nd5ydMt1w5vPOfAAAABeEEBZpAAADHQAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAIAAAAAAAAAAAAAAAAAAAADAAAAAAAAAzUAAAAAZOyKDgAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
    ),
}
```

However any next time, works well... very strange:
