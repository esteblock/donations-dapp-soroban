#![no_std]
#![no_std]
use soroban_sdk::{

    contract, contractimpl  
};


pub trait DonationsTrait {
}

#[contract]
struct Donations;

#[contractimpl]
impl DonationsTrait for Donations {
}
