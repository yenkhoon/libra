//! account: dd, 0, 0, address
// Test the concurrent preburn-burn flow

// register blessed as a preburn entity
//! sender: blessed
script {
use 0x1::LibraAccount;
use 0x1::Coin1::Coin1;

// register dd as a preburner
fun main(account: &signer) {
    LibraAccount::create_designated_dealer<Coin1>(
        account,
        {{dd}},
        {{dd::auth_key}},
    );
    LibraAccount::tiered_mint<Coin1>(
        account,
        {{dd}},
        600,
        0,
    );
}
}
// check: EXECUTED

// perform three preburns: 100, 200, 300
//! new-transaction
//! sender: dd
//! gas-currency: Coin1
script {
use 0x1::Coin1::Coin1;
use 0x1::Libra;
use 0x1::LibraAccount;
fun main(account: &signer) {
    let with_cap = LibraAccount::extract_withdraw_capability(account);
    LibraAccount::preburn<Coin1>(account, &with_cap, 100);
    LibraAccount::preburn<Coin1>(account, &with_cap, 200);
    LibraAccount::preburn<Coin1>(account, &with_cap, 300);
    assert(Libra::preburn_value<Coin1>() == 600, 8001);
    LibraAccount::restore_withdraw_capability(with_cap);
}
}

// check: PreburnEvent
// check: PreburnEvent
// check: PreburnEvent
// check: EXECUTED

// perform three burns. order should match the preburns
//! new-transaction
//! sender: blessed
script {
use 0x1::Coin1::Coin1;
use 0x1::Libra;
fun main(account: &signer) {
    let burn_address = {{dd}};
    Libra::burn<Coin1>(account, burn_address);
    assert(Libra::preburn_value<Coin1>() == 500, 8002);
    Libra::burn<Coin1>(account, burn_address);
    assert(Libra::preburn_value<Coin1>() == 300, 8003);
    Libra::burn<Coin1>(account, burn_address);
    assert(Libra::preburn_value<Coin1>() == 0, 8004)
}
}

// check: BurnEvent
// check: BurnEvent
// check: BurnEvent
// check: EXECUTED
