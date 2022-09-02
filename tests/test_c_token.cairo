%lang starknet

from starkware.cairo.common.bool import FALSE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256

from contracts.interfaces.i_c_token import IcToken
from contracts.libraries.math.wad_ray_math import RAY

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
        # context.pool = deploy_contract("./contracts/protocol/pool.cairo", []).contract_address
        context.token = deploy_contract("./lib/cairo_contracts/src/openzeppelin/token/erc20/presets/ERC20.cairo", [ids.NAME, ids.SYMBOL, ids.DECIMALS, ids.INITIAL_SUPPLY_LOW, ids.INITIAL_SUPPLY_HIGH, ids.PRANK_USER_1]).contract_address
        context.c_token = deploy_contract("./contracts/protocol/c_token.cairo", [context.token]).contract_address
    %}
    return ()
end

func get_contract_addresses() -> (
    token_address : felt, a_token_address : felt
):
    tempvar token
    tempvar c_token
    %{ ids.token = context.token %}
    %{ ids.c_token = context.c_token %}
    return (token, c_token)
end

@view
func test_constructor{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    let (local token, local c_token) = get_contract_addresses()

    let (asset_after) = IcToken.UNDERLYING_ASSET_ADDRESS(c_token)
    assert asset_after = token

    let (name_set) = IcToken.name(c_token)
    assert name_set = NAME

    let (symbol_set) = IcToken.symbol(c_token)
    assert symbol_set = SYMBOL

    return ()
end

# @view
# func test_balance_of{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
#     alloc_locals
#     let (local pool, local token, local a_token) = get_contract_addresses()

#     IAToken.mint(a_token, 0, PRANK_USER_1, Uint256(100, 0), Uint256(RAY, 0))

#     %{ stop_mock = mock_call(ids.pool, "get_reserve_normalized_income", [ids.RAY, 0]) %}
#     let (balance_prank_user_1) = IAToken.balanceOf(a_token, PRANK_USER_1)
#     assert balance_prank_user_1 = Uint256(100, 0)
#     %{ stop_mock() %}

#     %{ stop_mock = mock_call(ids.pool, "get_reserve_normalized_income", [2 * ids.RAY, 0]) %}
#     let (balance_prank_user_1) = IAToken.balanceOf(a_token, PRANK_USER_1)
#     assert balance_prank_user_1 = Uint256(200, 0)
#     %{ stop_mock() %}

#     return ()
# end
