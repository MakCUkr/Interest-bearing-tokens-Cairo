%lang starknet

from starkware.cairo.common.bool import FALSE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256

from contracts.interfaces.i_c_token import IcToken
from contracts.interfaces.i_c_pool import IcPool

const PRANK_USER_1 = 111
const PRANK_USER_2 = 222
const NAME = 109214297711982 # cToken
const SYMBOL = 1666468686 # cTKN
const DECIMALS = 18
const INITIAL_SUPPLY_LOW = 1000
const INITIAL_SUPPLY_HIGH = 0

@view
func __setup__{syscall_ptr : felt*, range_check_ptr}():
    %{
        context.c_pool = deploy_contract("./contracts/protocol/c_pool.cairo", []).contract_address
        context.token = deploy_contract("./lib/cairo_contracts/src/openzeppelin/token/erc20/presets/ERC20.cairo", [ids.NAME, ids.SYMBOL, ids.DECIMALS, ids.INITIAL_SUPPLY_LOW, ids.INITIAL_SUPPLY_HIGH, ids.PRANK_USER_1]).contract_address
        context.c_token = deploy_contract("./contracts/protocol/c_token.cairo", [context.token, context.c_pool]).contract_address
    %}
    return ()
end

func get_contract_addresses() -> (
    token_address : felt, a_token_address : felt, c_pool: felt
):
    tempvar token
    tempvar c_token
    tempvar c_pool
    %{ ids.c_pool = context.c_pool %}
    %{ ids.token = context.token %}
    %{ ids.c_token = context.c_token %}
    return (c_pool, token, c_token)
end

@view
func test_constructor{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    let (local c_pool, local token, local c_token) = get_contract_addresses()

    let (asset_after) = IcToken.UNDERLYING_ASSET_ADDRESS(c_token)
    assert asset_after = token

    let (name_set) = IcToken.name(c_token)
    assert name_set = NAME

    let (symbol_set) = IcToken.symbol(c_token)
    assert symbol_set = SYMBOL

    return ()
end

@view
func test_get_token_value{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
     
    let (local c_pool, local token, local c_token) = get_contract_addresses()
    let rand_uint = Uint256(100,0)
    let (equivalent_value) = IcToken.get_token_value(c_token, rand_uint)
    assert equivalent_value = Uint256(90,0)

    return ()
end


@view
func test_get_c_token_value{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
     
    let (local c_pool, local token, local c_token) = get_contract_addresses()
    let rand_uint = Uint256(100,0)
    let (equivalent_value) = IcToken.get_c_token_value(c_token, rand_uint)
    assert equivalent_value = Uint256(110,0)

    return ()
end