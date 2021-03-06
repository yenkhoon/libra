address 0x1 {

module LibraVersion {
    use 0x1::CoreAddresses;
    use 0x1::LibraConfig;
    use 0x1::Signer;

    struct LibraVersion {
        major: u64,
    }

    public fun initialize(
        lr_account: &signer,
    ) {
        assert(Signer::address_of(lr_account) == CoreAddresses::LIBRA_ROOT_ADDRESS(), 1);

        LibraConfig::publish_new_config<LibraVersion>(
            lr_account,
            LibraVersion { major: 1 },
        );
    }

    public fun set(account: &signer, major: u64) {
        let old_config = LibraConfig::get<LibraVersion>();

        assert(
            old_config.major < major,
            25
        );

        LibraConfig::set<LibraVersion>(
            account,
            LibraVersion { major }
        );
    }
}

}
