%lang starknet

from starkware.cairo.common.bool import FALSE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256

from contracts.interfaces.i_a_token import IAToken
from contracts.libraries.math.wad_ray_math import RAY

const PRANK_USER_1 = 111
const PRANK_USER_2 = 222
const NAME = 123
const SYMBOL = 456
const DECIMALS = 18
const INITIAL_SUPPLY_LOW = 1000
const INITIAL_SUPPLY_HIGH = 0

@view
func __setup__{syscall_ptr : felt*, range_check_ptr}():
    %{
        # context.pool = deploy_contract("./contracts/protocol/pool.cairo", []).contract_address
        context.pool = 111
        context.token = deploy_contract("./lib/cairo_contracts/src/openzeppelin/token/erc20/presets/ERC20.cairo", [ids.NAME, ids.SYMBOL, ids.DECIMALS, ids.INITIAL_SUPPLY_LOW, ids.INITIAL_SUPPLY_HIGH, ids.PRANK_USER_1]).contract_address
        context.a_token = deploy_contract("./contracts/protocol/a_token.cairo", [context.pool, context.token, ids.DECIMALS, ids.NAME+1, ids.SYMBOL+1]).contract_address
    %}
    return ()
end

func get_contract_addresses() -> (
    pool_address : felt, token_address : felt, a_token_address : felt
):
    tempvar pool
    tempvar token
    tempvar a_token
    %{ ids.pool = context.pool %}
    %{ ids.token = context.token %}
    %{ ids.a_token = context.a_token %}
    return (pool, token, a_token)
end

@view
func test_constructor{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    let (local pool, local token, local a_token) = get_contract_addresses()

    let (asset_after) = IAToken.UNDERLYING_ASSET_ADDRESS(a_token)
    assert asset_after = token
    let (pool_after) = IAToken.POOL(a_token)
    assert pool_after = pool
    return ()
end

@view
func test_balance_of{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    let (local pool, local token, local a_token) = get_contract_addresses()

    IAToken.mint(a_token, 0, PRANK_USER_1, Uint256(100, 0), Uint256(RAY, 0))

    %{ stop_mock = mock_call(ids.pool, "get_reserve_normalized_income", [ids.RAY, 0]) %}
    let (balance_prank_user_1) = IAToken.balanceOf(a_token, PRANK_USER_1)
    assert balance_prank_user_1 = Uint256(100, 0)
    %{ stop_mock() %}

    %{ stop_mock = mock_call(ids.pool, "get_reserve_normalized_income", [2 * ids.RAY, 0]) %}
    let (balance_prank_user_1) = IAToken.balanceOf(a_token, PRANK_USER_1)
    assert balance_prank_user_1 = Uint256(200, 0)
    %{ stop_mock() %}

    return ()
end
