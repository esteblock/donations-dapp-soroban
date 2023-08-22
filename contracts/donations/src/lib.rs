#![no_std]
#![no_std]
use soroban_sdk::{
    contract, contractimpl, Env, Address, Val, TryFromVal, ConversionError
};



#[derive(Clone, Copy)]
pub enum DataKey {
    AcceptedToken = 0,        // address of the accepted token
    DonationsRecipient =1,       // address of the donations recipient
}

impl TryFromVal<Env, DataKey> for Val {
    type Error = ConversionError;

    fn try_from_val(_env: &Env, v: &DataKey) -> Result<Self, Self::Error> {
        Ok((*v as u32).into())
    }
}



fn put_token_address(e: &Env, token: &Address) {
    e.storage().instance().set(&DataKey::AcceptedToken, token);
}

fn put_donations_recipient(e: &Env, recipient: &Address) {
    e.storage().instance().set(&DataKey::DonationsRecipient, recipient);
}

fn get_token_address(e: &Env) -> Address {
    e.storage()
        .instance()
        .get(&DataKey::AcceptedToken)
        .expect("not initialized")
}

fn get_donations_recipient(e: &Env) -> Address {
    e.storage()
        .instance()
        .get(&DataKey::AcceptedToken)
        .expect("not DonationsRecipient")
}

pub trait DonationsTrait {
    // Sets the recepient address and the token that will be accepted as donation
    fn initialize(e: Env, recipient: Address, token: Address);

    // Donates amount units of the accepted token
    fn donate(e: Env, amount: i128);

    // Transfer all the accumulated donations to the recipient. Can be called by anyone
    fn withdraw(e: Env);

    // Get the token address that is accepted as donations
    fn token(e:Env) -> Address;

    // Get the donations recipient address
    fn recipient(e:Env) -> Address;
}

#[contract]
struct Donations;

#[contractimpl]
impl DonationsTrait for Donations {

    // Sets the recepient address and the token that will be accepted as donation
    fn initialize(e: Env, recipient: Address, token: Address){
        assert!(
            !e.storage().instance().has(&DataKey::AcceptedToken),
            "already initialized"
        );
        put_token_address(&e, &token);
        put_donations_recipient(&e, &recipient);
    }

    // Donates amount units of the accepted token
    fn donate(e: Env, amount: i128){}

    // Transfer all the accumulated donations to the recipient. Can be called by anyone
    fn withdraw(e: Env){}

    // Get the token address that is accepted as donations
    fn token(e:Env) -> Address{
        get_token_address(&e)
    }

    // Get the donations recipient address
    fn recipient(e:Env) -> Address{
        get_donations_recipient(&e)
    }

}
