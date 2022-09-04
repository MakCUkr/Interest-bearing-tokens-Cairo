%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.uint256 import Uint256, uint256_sub, uint256_add, uint256_eq
from starkware.starknet.common.syscalls import get_contract_address

#
# Storage
#

@storage_var
func pool_token_balance() -> (res: Uint256):
end

@storage_var
func pool_cToken_balance() -> (res: Uint256):
end

namespace CPool:
    @view
    func get_token_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (_bal : Uint256):
        let (bal) = pool_token_balance.read()
        return (bal)
    end

    @view
    func get_c_token_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (_bal : Uint256):
        let (bal) = pool_cToken_balance.read()
        return (bal)
    end

    @external
    func set_token_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        amount : Uint256
    ):
        pool_token_balance.write(amount)
        return()
    end

    @external
    func set_cToken_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        amount : Uint256
    ):
        pool_cToken_balance.write(amount)
        return()
    end
end