%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.uint256 import Uint256, uint256_sub, uint256_add, uint256_eq
from starkware.starknet.common.syscalls import get_contract_address

#
# Storage
#


#
# Constructor
#

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    return ()
end

#
# Getters
#

@view
func get_token_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (_bal : Uint256):
    let bal = Uint256(1000,0)
    return (bal)
end

@view
func get_c_token_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (_bal : Uint256):
    let bal = Uint256(1100,0)
    return (bal)
end
