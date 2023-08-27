#![cfg(test)]

extern crate std;
// use soroban_sdk::testutils::{register_test_contract as register_donation, Donation};
use soroban_sdk::{
    testutils::{Address as AddressTestTrait},

    token, Address, Env, Bytes
};

use soroban_sdk::xdr::{Asset, ContractIdPreimage, WriteXdr};

use crate::{DonationsClient};

fn create_donations_contract<'a>(
    e: &'a Env,
    recipient: &'a Address,
    token: &'a Address,
) -> DonationsClient<'a> {
    let donations = DonationsClient::new(e, &e.register_contract(None, crate::Donations {}));
    donations.initialize(&recipient, token);
    donations
}

fn native_asset_contract_address(e: &Env) -> Address {
    let native_asset = Asset::Native;
    let contract_id_preimage = ContractIdPreimage::Asset(native_asset);
    let bytes = Bytes::from_slice(&e, &contract_id_preimage.to_xdr().unwrap());
    let native_asset_address = Address::from_contract_id(&e.crypto().sha256(&bytes));
    native_asset_address
}

#[test]
fn test_native() {
    let e: Env = Default::default();
    e.mock_all_auths();

    // Set the identities that will be used in the test
    let _creator = Address::random(&e);
    let recipient = Address::random(&e);
    let _donor = Address::random(&e);
    
    // Set the native token address
    // TODO: Test the address. Not not working
    // Check this: https://discord.com/channels/897514728459468821/1145458616086843423/1145458616086843423
    let native_address =native_asset_contract_address(&e);
    //let expected_address_string="CDF3YSDVBXV3QU2QSOZ55L4IVR7UZ74HIJKXNJMN4K5MOVFM3NDBNMLY";
    //assert_eq!(native_address, expected_address_string);
    

    // Deploy the donations contract with the recipient and the native address
    let donations = create_donations_contract(&e, &recipient, &native_address);

    // Let's test basic configuration:
    assert_eq!(donations.recipient(), recipient);
    assert_eq!(donations.token(), native_address);

    /*
    Create a native token client
    Call some function in the native token
    TODO: We cannot call functions in the native token:
    Check this: https://discord.com/channels/897514728459468821/1145462925109231726/1145462925109231726
    */
    //let native_client = token::Client::new(&e, &native_address);
    // assert_eq!(native_client.name(), String::from_slice(&e, "native"));

}