// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity <0.9.0 >=0.4.11 >=0.4.16 >=0.5.12 >=0.8.0 >=0.8.13 ^0.8.20 ^0.8.21 ^0.8.22 ^0.8.24;

// Provenance: `forge flatten` of sky-ecosystem/usds@master (commit d65551dbc11cfe1afcc4718ab790663b99d766af) and
// sky-ecosystem/sdai@susds (commit dfc7f41cb7599afcb0f0eb1ddaadbf9dd4015dce): the `UsdsDeploy` and `SUsdsDeploy` libraries and the token
// implementations they deploy. Flattened together from this repo, so `dss-test`'s ScriptTools and the
// OpenZeppelin sources resolve once and are not duplicated.
// Flattened rather than submoduled: submodules here are only for what `src/` imports.
// Compiled under this repo's settings, so behavior is faithful but the bytecode is not bit-identical
// to the deployed/audited artifact. Regenerate via `forge flatten`; do not hand-edit.

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/AuthGemJoinAbstract.sol

// https://github.com/makerdao/dss-deploy/blob/master/src/join.sol
interface AuthGemJoinAbstract {
    function vat() external view returns (address);
    function ilk() external view returns (bytes32);
    function gem() external view returns (address);
    function dec() external view returns (uint256);
    function live() external view returns (uint256);
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function cage() external;
    function join(address, uint256) external;
    function exit(address, uint256) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/CatAbstract.sol

// https://github.com/makerdao/dss/blob/master/src/cat.sol
interface CatAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function box() external view returns (uint256);
    function litter() external view returns (uint256);
    function ilks(bytes32) external view returns (address, uint256, uint256);
    function live() external view returns (uint256);
    function vat() external view returns (address);
    function vow() external view returns (address);
    function file(bytes32, address) external;
    function file(bytes32, uint256) external;
    function file(bytes32, bytes32, uint256) external;
    function file(bytes32, bytes32, address) external;
    function bite(bytes32, address) external returns (uint256);
    function claw(uint256) external;
    function cage() external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/ChainlogAbstract.sol

// https://github.com/makerdao/dss-chain-log
interface ChainlogAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function keys() external view returns (bytes32[] memory);
    function version() external view returns (string memory);
    function ipfs() external view returns (string memory);
    function setVersion(string calldata) external;
    function setSha256sum(string calldata) external;
    function setIPFS(string calldata) external;
    function setAddress(bytes32,address) external;
    function removeAddress(bytes32) external;
    function count() external view returns (uint256);
    function get(uint256) external view returns (bytes32,address);
    function list() external view returns (bytes32[] memory);
    function getAddress(bytes32) external view returns (address);
}

// Helper function for returning address or abstract of Chainlog
//  Valid on Mainnet, Kovan, Rinkeby, Ropsten, and Goerli
contract ChainlogHelper {
    address          public constant ADDRESS  = 0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F;
    ChainlogAbstract public constant ABSTRACT = ChainlogAbstract(ADDRESS);
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/ClipAbstract.sol

/// ClipAbstract.sol -- Clip Interface

// Copyright (C) 2021 Maker Ecosystem Growth Holdings, INC.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

interface ClipAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function ilk() external view returns (bytes32);
    function vat() external view returns (address);
    function dog() external view returns (address);
    function vow() external view returns (address);
    function spotter() external view returns (address);
    function calc() external view returns (address);
    function buf() external view returns (uint256);
    function tail() external view returns (uint256);
    function cusp() external view returns (uint256);
    function chip() external view returns (uint64);
    function tip() external view returns (uint192);
    function chost() external view returns (uint256);
    function kicks() external view returns (uint256);
    function active(uint256) external view returns (uint256);
    function sales(uint256) external view returns (uint256,uint256,uint256,address,uint96,uint256);
    function stopped() external view returns (uint256);
    function file(bytes32,uint256) external;
    function file(bytes32,address) external;
    function kick(uint256,uint256,address,address) external returns (uint256);
    function redo(uint256,address) external;
    function take(uint256,uint256,uint256,address,bytes calldata) external;
    function count() external view returns (uint256);
    function list() external view returns (uint256[] memory);
    function getStatus(uint256) external view returns (bool,uint256,uint256,uint256);
    function upchost() external;
    function yank(uint256) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/ClipperMomAbstract.sol

// https://github.com/makerdao/Clipper-mom/blob/master/src/ClipperMom.sol
interface ClipperMomAbstract {
    function owner() external view returns (address);
    function authority() external view returns (address);
    function locked(address) external view returns (uint256);
    function tolerance(address) external view returns (uint256);
    function spotter() external view returns (address);
    function setOwner(address) external;
    function setAuthority(address) external;
    function setPriceTolerance(address, uint256) external;
    function setBreaker(address, uint256, uint256) external;
    function tripBreaker(address) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/CureAbstract.sol

// https://github.com/makerdao/dss/blob/master/src/cure.sol
interface CureAbstract {
    function wards(address) external view returns (uint256);
    function live() external view returns (uint256);
    function srcs(uint256) external view returns (address);
    function wait() external view returns (uint256);
    function when() external view returns (uint256);
    function pos(address) external view returns (uint256);
    function amt(address) external view returns (uint256);
    function loadded(address) external view returns (uint256);
    function lCount() external view returns (uint256);
    function say() external view returns (uint256);
    function tCount() external view returns (uint256);
    function list() external view returns (address[] memory);
    function tell() external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function file(bytes32, uint256) external;
    function lift(address) external;
    function drop(address) external;
    function cage() external;
    function load(address) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dapp/DSAuthorityAbstract.sol

// https://github.com/dapphub/ds-auth
interface DSAuthorityAbstract {
    function canCall(address, address, bytes4) external view returns (bool);
}

interface DSAuthAbstract {
    function authority() external view returns (address);
    function owner() external view returns (address);
    function setOwner(address) external;
    function setAuthority(address) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dapp/DSChiefAbstract.sol

// https://github.com/dapphub/ds-chief
interface DSChiefAbstract {
    function live() external view returns (uint256);
    function launch() external;
    function slates(bytes32) external view returns (address[] memory);
    function votes(address) external view returns (bytes32);
    function approvals(address) external view returns (uint256);
    function deposits(address) external view returns (address);
    function GOV() external view returns (address);
    function IOU() external view returns (address);
    function hat() external view returns (address);
    function MAX_YAYS() external view returns (uint256);
    function lock(uint256) external;
    function free(uint256) external;
    function etch(address[] calldata) external returns (bytes32);
    function vote(address[] calldata) external returns (bytes32);
    function vote(bytes32) external;
    function lift(address) external;
    function setOwner(address) external;
    function setAuthority(address) external;
    function isUserRoot(address) external view returns (bool);
    function setRootUser(address, bool) external;
    function _root_users(address) external view returns (bool);
    function _user_roles(address) external view returns (bytes32);
    function _capability_roles(address, bytes4) external view returns (bytes32);
    function _public_capabilities(address, bytes4) external view returns (bool);
    function getUserRoles(address) external view returns (bytes32);
    function getCapabilityRoles(address, bytes4) external view returns (bytes32);
    function isCapabilityPublic(address, bytes4) external view returns (bool);
    function hasUserRole(address, uint8) external view returns (bool);
    function canCall(address, address, bytes4) external view returns (bool);
    function setUserRole(address, uint8, bool) external;
    function setPublicCapability(address, bytes4, bool) external;
    function setRoleCapability(uint8, address, bytes4, bool) external;
}

interface DSChiefFabAbstract {
    function newChief(address, uint256) external returns (address);
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dapp/DSPauseAbstract.sol

// https://github.com/dapphub/ds-pause
interface DSPauseAbstract {
    function owner() external view returns (address);
    function authority() external view returns (address);
    function setOwner(address) external;
    function setAuthority(address) external;
    function setDelay(uint256) external;
    function plans(bytes32) external view returns (bool);
    function proxy() external view returns (address);
    function delay() external view returns (uint256);
    function plot(address, bytes32, bytes calldata, uint256) external;
    function drop(address, bytes32, bytes calldata, uint256) external;
    function exec(address, bytes32, bytes calldata, uint256) external returns (bytes memory);
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dapp/DSPauseProxyAbstract.sol

// https://github.com/dapphub/ds-pause
interface DSPauseProxyAbstract {
    function owner() external view returns (address);
    function exec(address, bytes calldata) external returns (bytes memory);
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dapp/DSRolesAbstract.sol

// https://github.com/dapphub/ds-roles
interface DSRolesAbstract {
    function _root_users(address) external view returns (bool);
    function _user_roles(address) external view returns (bytes32);
    function _capability_roles(address, bytes4) external view returns (bytes32);
    function _public_capabilities(address, bytes4) external view returns (bool);
    function getUserRoles(address) external view returns (bytes32);
    function getCapabilityRoles(address, bytes4) external view returns (bytes32);
    function isUserRoot(address) external view returns (bool);
    function isCapabilityPublic(address, bytes4) external view returns (bool);
    function hasUserRole(address, uint8) external view returns (bool);
    function canCall(address, address, bytes4) external view returns (bool);
    function setRootUser(address, bool) external;
    function setUserRole(address, uint8, bool) external;
    function setPublicCapability(address, bytes4, bool) external;
    function setRoleCapability(uint8, address, bytes4, bool) external;
    function authority() external view returns (address);
    function owner() external view returns (address);
    function setOwner(address) external;
    function setAuthority(address) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dapp/DSRuneAbstract.sol

// Copyright (C) 2020 Maker Foundation
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// https://github.com/makerdao/dss-spellbook
interface DSRuneAbstract {
    // @return [address] A contract address conforming to DSPauseAbstract
    function pause()    external view returns (address);
    // @return [address] The address of the contract to be executed
    // TODO: is `action()` a required field? Not all spells rely on a seconary contract.
    function action()   external view returns (address);
    // @return [bytes32] extcodehash of rune address
    function tag()      external view returns (bytes32);
    // @return [bytes] The `abi.encodeWithSignature()` result of the function to be called.
    function sig()      external view returns (bytes memory);
    // @return [uint256] Earliest time rune can execute
    function eta()      external view returns (uint256);
    // The schedule() function plots the rune in the DSPause
    function schedule() external;
    // @return [bool] true if the rune has been cast()
    function done()     external view returns (bool);
    // The cast() function executes the rune
    function cast()     external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dapp/DSSpellAbstract.sol

// https://github.com/dapphub/ds-spell
interface DSSpellAbstract {
    function whom() external view returns (address);
    function mana() external view returns (uint256);
    function data() external view returns (bytes memory);
    function done() external view returns (bool);
    function cast() external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dapp/DSThingAbstract.sol

// https://github.com/dapphub/ds-thing
interface DSThingAbstract {
    function authority() external view returns (address);
    function owner() external view returns (address);
    function setOwner(address) external;
    function setAuthority(address) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dapp/DSTokenAbstract.sol

// https://github.com/dapphub/ds-token/blob/master/src/token.sol
interface DSTokenAbstract {
    function name() external view returns (bytes32);
    function symbol() external view returns (bytes32);
    function decimals() external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function transfer(address, uint256) external returns (bool);
    function allowance(address, address) external view returns (uint256);
    function approve(address, uint256) external returns (bool);
    function approve(address) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function push(address, uint256) external;
    function pull(address, uint256) external;
    function move(address, address, uint256) external;
    function mint(uint256) external;
    function mint(address,uint) external;
    function burn(uint256) external;
    function burn(address,uint) external;
    function setName(bytes32) external;
    function authority() external view returns (address);
    function owner() external view returns (address);
    function setOwner(address) external;
    function setAuthority(address) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dapp/DSValueAbstract.sol

// https://github.com/dapphub/ds-value/blob/master/src/value.sol
interface DSValueAbstract {
    function has() external view returns (bool);
    function val() external view returns (bytes32);
    function peek() external view returns (bytes32, bool);
    function read() external view returns (bytes32);
    function poke(bytes32) external;
    function void() external;
    function authority() external view returns (address);
    function owner() external view returns (address);
    function setOwner(address) external;
    function setAuthority(address) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/DaiAbstract.sol

// https://github.com/makerdao/dss/blob/master/src/dai.sol
interface DaiAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function version() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function allowance(address, address) external view returns (uint256);
    function nonces(address) external view returns (uint256);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external view returns (bytes32);
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function mint(address, uint256) external;
    function burn(address, uint256) external;
    function approve(address, uint256) external returns (bool);
    function push(address, uint256) external;
    function pull(address, uint256) external;
    function move(address, address, uint256) external;
    function permit(address, address, uint256, uint256, bool, uint8, bytes32, bytes32) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/DaiJoinAbstract.sol

// https://github.com/makerdao/dss/blob/master/src/join.sol
interface DaiJoinAbstract {
    function wards(address) external view returns (uint256);
    function rely(address usr) external;
    function deny(address usr) external;
    function vat() external view returns (address);
    function dai() external view returns (address);
    function live() external view returns (uint256);
    function cage() external;
    function join(address, uint256) external;
    function exit(address, uint256) external;
}

// lib/usds/src/DaiUsds.sol

/// DaiUsds.sol -- Dai/Usds Exchanger

// Copyright (C) 2023 Dai Foundation
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

interface JoinLike {
    function vat() external view returns (address);
    function join(address, uint256) external;
    function exit(address, uint256) external;
}

interface DaiJoinLike_0 is JoinLike {
    function dai() external view returns (address);
}

interface UsdsJoinLike is JoinLike {
    function usds() external view returns (address);
}

interface GemLike {
    function approve(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
}

interface VatLike_0 {
    function hope(address) external;
}

contract DaiUsds {
    DaiJoinLike_0  public immutable daiJoin;
    UsdsJoinLike public immutable usdsJoin;
    GemLike      public immutable dai;
    GemLike      public immutable usds;
    
    event DaiToUsds(address indexed caller, address indexed usr, uint256 wad);
    event UsdsToDai(address indexed caller, address indexed usr, uint256 wad);

    constructor(address daiJoin_, address usdsJoin_) {
        daiJoin  = DaiJoinLike_0(daiJoin_);
        usdsJoin = UsdsJoinLike(usdsJoin_);

        address vat = daiJoin.vat();
        require(vat == usdsJoin.vat(), "DaiUsds/vat-not-same");

        dai  = GemLike(daiJoin.dai());
        usds = GemLike(usdsJoin.usds());

        dai.approve(address(daiJoin), type(uint256).max);
        usds.approve(address(usdsJoin), type(uint256).max);

        VatLike_0(vat).hope(address(daiJoin));
        VatLike_0(vat).hope(address(usdsJoin));
    }

    function daiToUsds(address usr, uint256 wad) external {
        dai.transferFrom(msg.sender, address(this), wad);
        daiJoin.join(address(this), wad);
        usdsJoin.exit(usr, wad);
        emit DaiToUsds(msg.sender, usr, wad);
    }

    function usdsToDai(address usr, uint256 wad) external {
        usds.transferFrom(msg.sender, address(this), wad);
        usdsJoin.join(address(this), wad);
        daiJoin.exit(usr, wad);
        emit UsdsToDai(msg.sender, usr, wad);
    }
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/DogAbstract.sol

/// DogAbstract.sol -- Dog Interface

// Copyright (C) 2021 Maker Ecosystem Growth Holdings, INC.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

interface DogAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function vat() external view returns (address);
    function ilks(bytes32) external view returns (address,uint256,uint256,uint256);
    function vow() external view returns (address);
    function live() external view returns (uint256);
    function Hole() external view returns (uint256);
    function Dirt() external view returns (uint256);
    function file(bytes32,address) external;
    function file(bytes32,uint256) external;
    function file(bytes32,bytes32,uint256) external;
    function file(bytes32,bytes32,address) external;
    function chop(bytes32) external view returns (uint256);
    function bark(bytes32,address,address) external returns (uint256);
    function digs(bytes32,uint256) external;
    function cage() external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/DssAutoLineAbstract.sol

// https://github.com/makerdao/dss-auto-line/blob/master/src/DssAutoLine.sol
interface DssAutoLineAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function vat() external view returns (address);
    function ilks(bytes32) external view returns (uint256,uint256,uint48,uint48,uint48);
    function setIlk(bytes32,uint256,uint256,uint256) external;
    function remIlk(bytes32) external;
    function exec(bytes32) external returns (uint256);
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/DssCdpManager.sol

// https://github.com/makerdao/dss-cdp-manager/
interface DssCdpManagerAbstract {
    function vat() external view returns (address);
    function cdpi() external view returns (uint256);
    function urns(uint256) external view returns (address);
    function list(uint256) external view returns (uint256,uint256);
    function owns(uint256) external view returns (address);
    function ilks(uint256) external view returns (bytes32);
    function first(address) external view returns (uint256);
    function last(address) external view returns (uint256);
    function count(address) external view returns (uint256);
    function cdpCan(address, uint256, address) external returns (uint256);
    function urnCan(address, address) external returns (uint256);
    function cdpAllow(uint256, address, uint256) external;
    function urnAllow(address, uint256) external;
    function open(bytes32, address) external returns (uint256);
    function give(uint256, address) external;
    function frob(uint256, int256, int256) external;
    function flux(uint256, address, uint256) external;
    function flux(bytes32, uint256, address, uint256) external;
    function move(uint256, address, uint256) external;
    function quit(uint256, address) external;
    function enter(address, uint256) external;
    function shift(uint256, uint256) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/ESMAbstract.sol

// https://github.com/makerdao/esm/blob/master/src/ESM.sol
interface ESMAbstract {
    function gem() external view returns (address);
    function proxy() external view returns (address);
    function wards(address) external view returns (uint256);
    function sum(address) external view returns (address);
    function Sum() external view returns (uint256);
    function min() external view returns (uint256);
    function end() external view returns (address);
    function live() external view returns (uint256);
    function revokesGovernanceAccess() external view returns (bool);
    function rely(address) external;
    function deny(address) external;
    function file(bytes32, uint256) external;
    function file(bytes32, address) external;
    function cage() external;
    function fire() external;
    function denyProxy(address) external;
    function join(uint256) external;
    function burn() external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/ETHJoinAbstract.sol

// https://github.com/makerdao/dss/blob/master/src/join.sol
interface ETHJoinAbstract {
    function wards(address) external view returns (uint256);
    function rely(address usr) external;
    function deny(address usr) external;
    function vat() external view returns (address);
    function ilk() external view returns (bytes32);
    function live() external view returns (uint256);
    function cage() external;
    function join(address) external payable;
    function exit(address, uint256) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/EndAbstract.sol

// https://github.com/makerdao/dss/blob/master/src/end.sol
interface EndAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function vat() external view returns (address);
    function cat() external view returns (address);
    function dog() external view returns (address);
    function vow() external view returns (address);
    function pot() external view returns (address);
    function spot() external view returns (address);
    function cure() external view returns (address);
    function live() external view returns (uint256);
    function when() external view returns (uint256);
    function wait() external view returns (uint256);
    function debt() external view returns (uint256);
    function tag(bytes32) external view returns (uint256);
    function gap(bytes32) external view returns (uint256);
    function Art(bytes32) external view returns (uint256);
    function fix(bytes32) external view returns (uint256);
    function bag(address) external view returns (uint256);
    function out(bytes32, address) external view returns (uint256);
    function file(bytes32, address) external;
    function file(bytes32, uint256) external;
    function cage() external;
    function cage(bytes32) external;
    function skip(bytes32, uint256) external;
    function snip(bytes32, uint256) external;
    function skim(bytes32, address) external;
    function free(bytes32) external;
    function thaw() external;
    function flow(bytes32) external;
    function pack(uint256) external;
    function cash(bytes32, uint256) external;
}

// node_modules/@openzeppelin/contracts/utils/Errors.sol

// OpenZeppelin Contracts (last updated v5.1.0) (utils/Errors.sol)

/**
 * @dev Collection of common custom errors used in multiple contracts
 *
 * IMPORTANT: Backwards compatibility is not guaranteed in future versions of the library.
 * It is recommended to avoid relying on the error API for critical functionality.
 *
 * _Available since v5.1._
 */
library Errors {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error InsufficientBalance(uint256 balance, uint256 needed);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedCall();

    /**
     * @dev The deployment failed.
     */
    error FailedDeployment();

    /**
     * @dev A necessary precompile is missing.
     */
    error MissingPrecompile(address);
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/ExponentialDecreaseAbstract.sol

/// ExponentialDecreaseAbstract.sol -- Exponential Decrease Interface

// Copyright (C) 2021 Maker Ecosystem Growth Holdings, INC.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

interface ExponentialDecreaseAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function cut() external view returns (uint256);
    function file(bytes32,uint256) external;
    function price(uint256,uint256) external view returns (uint256);
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/FaucetAbstract.sol

// https://github.com/makerdao/token-faucet/blob/master/src/RestrictedTokenFaucet.sol
interface FaucetAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function list(address) external view returns (uint256);
    function hope(address) external;
    function nope(address) external;
    function amt(address) external view returns (uint256);
    function done(address, address) external view returns (bool);
    function gulp(address) external;
    function gulp(address, address[] calldata) external;
    function shut(address) external;
    function undo(address, address) external;
    function setAmt(address, uint256) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/FlapAbstract.sol

// https://github.com/makerdao/dss/blob/master/src/flap.sol
interface FlapAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function bids(uint256) external view returns (uint256, uint256, address, uint48, uint48);
    function vat() external view returns (address);
    function gem() external view returns (address);
    function beg() external view returns (uint256);
    function ttl() external view returns (uint48);
    function tau() external view returns (uint48);
    function kicks() external view returns (uint256);
    function live() external view returns (uint256);
    function lid() external view returns (uint256);
    function fill() external view returns (uint256);
    function file(bytes32, uint256) external;
    function kick(uint256, uint256) external returns (uint256);
    function tick(uint256) external;
    function tend(uint256, uint256, uint256) external;
    function deal(uint256) external;
    function cage(uint256) external;
    function yank(uint256) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/FlashAbstract.sol

// https://github.com/makerdao/dss-flash/blob/master/src/flash.sol
interface FlashAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function vat() external view returns (address);
    function daiJoin() external view returns (address);
    function dai() external view returns (address);
    function vow() external view returns (address);
    function max() external view returns (uint256);
    function toll() external view returns (uint256);
    function CALLBACK_SUCCESS() external view returns (bytes32);
    function CALLBACK_SUCCESS_VAT_DAI() external view returns (bytes32);
    function file(bytes32, uint256) external;
    function maxFlashLoan(address) external view returns (uint256);
    function flashFee(address, uint256) external view returns (uint256);
    function flashLoan(address, address, uint256, bytes calldata) external returns (bool);
    function vatDaiFlashLoan(address, uint256, bytes calldata) external returns (bool);
    function convert() external;
    function accrue() external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/FlipAbstract.sol

// https://github.com/makerdao/dss/blob/master/src/flip.sol
interface FlipAbstract {
    function wards(address) external view returns (uint256);
    function rely(address usr) external;
    function deny(address usr) external;
    function bids(uint256) external view returns (uint256, uint256, address, uint48, uint48, address, address, uint256);
    function vat() external view returns (address);
    function cat() external view returns (address);
    function ilk() external view returns (bytes32);
    function beg() external view returns (uint256);
    function ttl() external view returns (uint48);
    function tau() external view returns (uint48);
    function kicks() external view returns (uint256);
    function file(bytes32, uint256) external;
    function kick(address, address, uint256, uint256, uint256) external returns (uint256);
    function tick(uint256) external;
    function tend(uint256, uint256, uint256) external;
    function dent(uint256, uint256, uint256) external;
    function deal(uint256) external;
    function yank(uint256) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/FlipperMomAbstract.sol

// https://github.com/makerdao/flipper-mom/blob/master/src/FlipperMom.sol
interface FlipperMomAbstract {
    function owner() external view returns (address);
    function authority() external view returns (address);
    function setOwner(address) external;
    function setAuthority(address) external;
    function cat() external returns (address);
    function rely(address) external;
    function deny(address) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/FlopAbstract.sol

// https://github.com/makerdao/dss/blob/master/src/flop.sol
interface FlopAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function bids(uint256) external view returns (uint256, uint256, address, uint48, uint48);
    function vat() external view returns (address);
    function gem() external view returns (address);
    function beg() external view returns (uint256);
    function pad() external view returns (uint256);
    function ttl() external view returns (uint48);
    function tau() external view returns (uint48);
    function kicks() external view returns (uint256);
    function live() external view returns (uint256);
    function vow() external view returns (address);
    function file(bytes32, uint256) external;
    function kick(address, uint256, uint256) external returns (uint256);
    function tick(uint256) external;
    function dent(uint256, uint256, uint256) external;
    function deal(uint256) external;
    function cage() external;
    function yank(uint256) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/ERC/GemAbstract.sol

// A base ERC-20 abstract class
// https://eips.ethereum.org/EIPS/eip-20
interface GemAbstract {
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function allowance(address, address) external view returns (uint256);
    function approve(address, uint256) external returns (bool);
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/GemJoinAbstract.sol

// https://github.com/makerdao/dss/blob/master/src/join.sol
interface GemJoinAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function vat() external view returns (address);
    function ilk() external view returns (bytes32);
    function gem() external view returns (address);
    function dec() external view returns (uint256);
    function live() external view returns (uint256);
    function cage() external;
    function join(address, uint256) external;
    function exit(address, uint256) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/GemJoinImplementationAbstract.sol

// https://github.com/makerdao/dss-deploy/blob/master/src/join.sol
interface GemJoinImplementationAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function vat() external view returns (address);
    function ilk() external view returns (bytes32);
    function gem() external view returns (address);
    function dec() external view returns (uint256);
    function live() external view returns (uint256);
    function cage() external;
    function join(address, uint256) external;
    function exit(address, uint256) external;
    function setImplementation(address, uint256) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/GemJoinManagedAbstract.sol

// https://github.com/makerdao/dss-gem-joins/blob/master/src/join-managed.sol
interface GemJoinManagedAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function vat() external view returns (address);
    function ilk() external view returns (bytes32);
    function gem() external view returns (address);
    function dec() external view returns (uint256);
    function live() external view returns (uint256);
    function cage() external;
    function join(address, uint256) external;
    function exit(address, address, uint256) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/sai/GemPitAbstract.sol

// https://github.com/makerdao/sai/blob/master/src/pit.sol
interface GemPitAbstract {
    function burn(address) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/GetCdpsAbstract.sol

// https://github.com/makerdao/dss-cdp-manager/blob/master/src/GetCdps.sol
interface GetCdpsAbstract {
    function getCdpsAsc(address, address) external view returns (uint256[] memory, address[] memory, bytes32[] memory);
    function getCdpsDesc(address, address) external view returns (uint256[] memory, address[] memory, bytes32[] memory);
}

// node_modules/@openzeppelin/contracts/proxy/beacon/IBeacon.sol

// OpenZeppelin Contracts (last updated v5.4.0) (proxy/beacon/IBeacon.sol)

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeacon {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {UpgradeableBeacon} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// node_modules/@openzeppelin/contracts/interfaces/IERC1967.sol

// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC1967.sol)

/**
 * @dev ERC-1967: Proxy Storage Slots. This interface contains the events defined in the ERC.
 */
interface IERC1967 {
    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Emitted when the beacon is changed.
     */
    event BeaconUpgraded(address indexed beacon);
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/IlkRegistryAbstract.sol

// https://github.com/makerdao/ilk-registry
interface IlkRegistryAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function vat() external view returns (address);
    function dog() external view returns (address);
    function cat() external view returns (address);
    function spot() external view returns (address);
    function ilkData(bytes32) external view returns (
        uint96, address, address, uint8, uint96, address, address, string memory, string memory
    );
    function ilks() external view returns (bytes32[] memory);
    function ilks(uint) external view returns (bytes32);
    function add(address) external;
    function remove(bytes32) external;
    function update(bytes32) external;
    function removeAuth(bytes32) external;
    function file(bytes32, address) external;
    function file(bytes32, bytes32, address) external;
    function file(bytes32, bytes32, uint256) external;
    function file(bytes32, bytes32, string calldata) external;
    function count() external view returns (uint256);
    function list() external view returns (bytes32[] memory);
    function list(uint256, uint256) external view returns (bytes32[] memory);
    function get(uint256) external view returns (bytes32);
    function info(bytes32) external view returns (
        string memory, string memory, uint256, uint256, address, address, address, address
    );
    function pos(bytes32) external view returns (uint256);
    function class(bytes32) external view returns (uint256);
    function gem(bytes32) external view returns (address);
    function pip(bytes32) external view returns (address);
    function join(bytes32) external view returns (address);
    function xlip(bytes32) external view returns (address);
    function dec(bytes32) external view returns (uint256);
    function symbol(bytes32) external view returns (string memory);
    function name(bytes32) external view returns (string memory);
    function put(bytes32, address, address, uint256, uint256, address, address, string calldata, string calldata) external;
}

// node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol

// OpenZeppelin Contracts (last updated v5.3.0) (proxy/utils/Initializable.sol)

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```solidity
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 *
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Storage of the initializable contract.
     *
     * It's implemented on a custom ERC-7201 namespace to reduce the risk of storage collisions
     * when using with upgradeable contracts.
     *
     * @custom:storage-location erc7201:openzeppelin.storage.Initializable
     */
    struct InitializableStorage {
        /**
         * @dev Indicates that the contract has been initialized.
         */
        uint64 _initialized;
        /**
         * @dev Indicates that the contract is in the process of being initialized.
         */
        bool _initializing;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Initializable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant INITIALIZABLE_STORAGE = 0xf0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a00;

    /**
     * @dev The contract is already initialized.
     */
    error InvalidInitialization();

    /**
     * @dev The contract is not initializing.
     */
    error NotInitializing();

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint64 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that in the context of a constructor an `initializer` may be invoked any
     * number of times. This behavior in the constructor can be useful during testing and is not expected to be used in
     * production.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        // Cache values to avoid duplicated sloads
        bool isTopLevelCall = !$._initializing;
        uint64 initialized = $._initialized;

        // Allowed calls:
        // - initialSetup: the contract is not in the initializing state and no previous version was
        //                 initialized
        // - construction: the contract is initialized at version 1 (no reinitialization) and the
        //                 current contract is just being deployed
        bool initialSetup = initialized == 0 && isTopLevelCall;
        bool construction = initialized == 1 && address(this).code.length == 0;

        if (!initialSetup && !construction) {
            revert InvalidInitialization();
        }
        $._initialized = 1;
        if (isTopLevelCall) {
            $._initializing = true;
        }
        _;
        if (isTopLevelCall) {
            $._initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: Setting the version to 2**64 - 1 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint64 version) {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing || $._initialized >= version) {
            revert InvalidInitialization();
        }
        $._initialized = version;
        $._initializing = true;
        _;
        $._initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        _checkInitializing();
        _;
    }

    /**
     * @dev Reverts if the contract is not in an initializing state. See {onlyInitializing}.
     */
    function _checkInitializing() internal view virtual {
        if (!_isInitializing()) {
            revert NotInitializing();
        }
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing) {
            revert InvalidInitialization();
        }
        if ($._initialized != type(uint64).max) {
            $._initialized = type(uint64).max;
            emit Initialized(type(uint64).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint64) {
        return _getInitializableStorage()._initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _getInitializableStorage()._initializing;
    }

    /**
     * @dev Pointer to storage slot. Allows integrators to override it with a custom storage location.
     *
     * NOTE: Consider following the ERC-7201 formula to derive storage locations.
     */
    function _initializableStorageSlot() internal pure virtual returns (bytes32) {
        return INITIALIZABLE_STORAGE;
    }

    /**
     * @dev Returns a pointer to the storage namespace.
     */
    // solhint-disable-next-line var-name-mixedcase
    function _getInitializableStorage() private pure returns (InitializableStorage storage $) {
        bytes32 slot = _initializableStorageSlot();
        assembly {
            $.slot := slot
        }
    }
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/JugAbstract.sol

// https://github.com/makerdao/dss/blob/master/src/jug.sol
interface JugAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function ilks(bytes32) external view returns (uint256, uint256);
    function vat() external view returns (address);
    function vow() external view returns (address);
    function base() external view returns (uint256);
    function init(bytes32) external;
    function file(bytes32, bytes32, uint256) external;
    function file(bytes32, uint256) external;
    function file(bytes32, address) external;
    function drip(bytes32) external returns (uint256);
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/LPOsmAbstract.sol

// https://github.com/makerdao/univ2-lp-oracle
interface LPOsmAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function stopped() external view returns (uint256);
    function bud(address) external view returns (uint256);
    function dec0() external view returns (uint8);
    function dec1() external view returns (uint8);
    function orb0() external view returns (address);
    function orb1() external view returns (address);
    function wat() external view returns (bytes32);
    function hop() external view returns (uint32);
    function src() external view returns (address);
    function zzz() external view returns (uint64);
    function change(address) external;
    function step(uint256) external;
    function stop() external;
    function start() external;
    function pass() external view returns (bool);
    function poke() external;
    function peek() external view returns (bytes32, bool);
    function peep() external view returns (bytes32, bool);
    function read() external view returns (bytes32);
    function kiss(address) external;
    function diss(address) external;
    function kiss(address[] calldata) external;
    function diss(address[] calldata) external;
    function link(uint256, address) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/LerpAbstract.sol

// https://github.com/makerdao/dss-lerp/blob/master/src/Lerp.sol
interface LerpAbstract {
    function target() external view returns (address);
    function what() external view returns (bytes32);
    function start() external view returns (uint256);
    function end() external view returns (uint256);
    function duration() external view returns (uint256);
    function done() external view returns (bool);
    function startTime() external view returns (uint256);
    function tick() external returns (uint256);
    function ilk() external view returns (bytes32);
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/LerpFactoryAbstract.sol

// https://github.com/makerdao/dss-lerp/blob/master/src/LerpFactory.sol
interface LerpFactoryAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function lerps(bytes32) external view returns (address);
    function active(uint256) external view returns (address);
    function newLerp(bytes32, address, bytes32, uint256, uint256, uint256, uint256) external returns (address);
    function newIlkLerp(bytes32, address, bytes32, bytes32, uint256, uint256, uint256, uint256) external returns (address);
    function tall() external;
    function count() external view returns (uint256);
    function list() external view returns (address[] memory);
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/LinearDecreaseAbstract.sol

/// LinearDecreaseAbstract.sol -- Linear Decrease Interface

// Copyright (C) 2021 Maker Ecosystem Growth Holdings, INC.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

interface LinearDecreaseAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function tau() external view returns (uint256);
    function file(bytes32,uint256) external;
    function price(uint256,uint256) external view returns (uint256);
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/MedianAbstract.sol

// https://github.com/makerdao/median
interface MedianAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function age() external view returns (uint32);
    function wat() external view returns (bytes32);
    function bar() external view returns (uint256);
    function orcl(address) external view returns (uint256);
    function bud(address) external view returns (uint256);
    function slot(uint8) external view returns (address);
    function read() external view returns (uint256);
    function peek() external view returns (uint256, bool);
    function lift(address[] calldata) external;
    function drop(address[] calldata) external;
    function setBar(uint256) external;
    function kiss(address) external;
    function diss(address) external;
    function kiss(address[] calldata) external;
    function diss(address[] calldata) external;
    function poke(uint256[] calldata, uint256[] calldata, uint8[] calldata, bytes32[] calldata, bytes32[] calldata) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/MkrAuthorityAbstract.sol

// https://github.com/makerdao/mkr-authority/blob/master/src/MkrAuthority.sol
interface MkrAuthorityAbstract {
    function root() external returns (address);
    function setRoot(address) external;
    function wards(address) external returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function canCall(address, address, bytes4) external returns (bool);
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/OsmAbstract.sol

// https://github.com/makerdao/osm
interface OsmAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function stopped() external view returns (uint256);
    function src() external view returns (address);
    function hop() external view returns (uint16);
    function zzz() external view returns (uint64);
    function bud(address) external view returns (uint256);
    function stop() external;
    function start() external;
    function change(address) external;
    function step(uint16) external;
    function void() external;
    function pass() external view returns (bool);
    function poke() external;
    function peek() external view returns (bytes32, bool);
    function peep() external view returns (bytes32, bool);
    function read() external view returns (bytes32);
    function kiss(address) external;
    function diss(address) external;
    function kiss(address[] calldata) external;
    function diss(address[] calldata) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/OsmMomAbstract.sol

// https://github.com/makerdao/osm-mom
interface OsmMomAbstract {
    function owner() external view returns (address);
    function authority() external view returns (address);
    function osms(bytes32) external view returns (address);
    function setOsm(bytes32, address) external;
    function setOwner(address) external;
    function setAuthority(address) external;
    function stop(bytes32) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/PotAbstract.sol

// https://github.com/makerdao/dss/blob/master/src/pot.sol
interface PotAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function pie(address) external view returns (uint256);
    function Pie() external view returns (uint256);
    function dsr() external view returns (uint256);
    function chi() external view returns (uint256);
    function vat() external view returns (address);
    function vow() external view returns (address);
    function rho() external view returns (uint256);
    function live() external view returns (uint256);
    function file(bytes32, uint256) external;
    function file(bytes32, address) external;
    function cage() external;
    function drip() external returns (uint256);
    function join(uint256) external;
    function exit(uint256) external;
}

// node_modules/@openzeppelin/contracts/proxy/Proxy.sol

// OpenZeppelin Contracts (last updated v5.0.0) (proxy/Proxy.sol)

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev This is a virtual function that should be overridden so it returns the address to which the fallback
     * function and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _fallback();
    }
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/PsmAbstract.sol

// https://github.com/makerdao/dss-psm/blob/master/src/psm.sol
interface PsmAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function vat() external view returns (address);
    function gemJoin() external view returns (address);
    function dai() external view returns (address);
    function daiJoin() external view returns (address);
    function ilk() external view returns (bytes32);
    function vow() external view returns (address);
    function tin() external view returns (uint256);
    function tout() external view returns (uint256);
    function file(bytes32 what, uint256 data) external;
    function hope(address) external;
    function nope(address) external;
    function sellGem(address usr, uint256 gemAmt) external;
    function buyGem(address usr, uint256 gemAmt) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/mip21/RwaInputConduitAbstract.sol
// SPDX-FileCopyrightText: © 2022 Dai Foundation <www.daifoundation.org>

interface RwaInputConduitBaseAbstract {
    function dai() external view returns (address);
    function to() external view returns (address);
    function push() external;
}

// https://github.com/makerdao/mip21-toolkit/blob/master/src/conduits/RwaInputConduit.sol
interface RwaInputConduitAbstract is RwaInputConduitBaseAbstract {
    function gov() external view returns (address);
}

// https://github.com/makerdao/mip21-toolkit/blob/master/src/conduits/RwaInputConduit2.sol
interface RwaInputConduit2Abstract is RwaInputConduitBaseAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function may(address) external view returns (uint256);
    function mate(address) external;
    function hate(address) external;
}

// https://github.com/makerdao/mip21-toolkit/blob/master/src/conduits/RwaInputConduit3.sol
interface RwaInputConduit3Abstract is RwaInputConduitBaseAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function may(address) external view returns (uint256);
    function mate(address) external;
    function hate(address) external;
    function psm() external view returns (address);
    function gem() external view returns (address);
    function quitTo() external view returns (address);
    function file(bytes32, address) external;
    function push(uint) external;
    function quit() external;
    function quit(uint) external;
    function yank(address, address, uint256) external;
    function expectedDaiWad(uint256) external view returns (uint256);
    function requiredGemAmt(uint256) external view returns (uint256);
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/mip21/RwaJarAbstract.sol
// SPDX-FileCopyrightText: © 2022 Dai Foundation <www.daifoundation.org>

// https://github.com/makerdao/mip21-toolkit/blob/master/src/jars/RwaJar.sol
interface RwaJarAbstract {
    function daiJoin() external view returns(address);
    function dai() external view returns(address);
    function chainlog() external view returns(address);
    function void() external;
    function toss(uint256) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/mip21/RwaLiquidationOracleAbstract.sol
// SPDX-FileCopyrightText: © 2022 Dai Foundation <www.daifoundation.org>

// https://github.com/makerdao/mip21-toolkit/blob/master/src/oracles/RwaLiquidationOracle.sol
interface RwaLiquidationOracleAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function vat() external view returns (address);
    function vow() external view returns (address);
    function ilks(bytes32) external view returns(string memory, address, uint48, uint48);
    function file(bytes32, address) external;
    function init(bytes32, uint256, string calldata, uint48) external;
    function bump(bytes32, uint256) external;
    function tell(bytes32) external;
    function cure(bytes32) external;
    function cull(bytes32, address) external;
    function good(bytes32) external view returns (bool);
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/mip21/RwaOutputConduitAbstract.sol
// SPDX-FileCopyrightText: © 2022 Dai Foundation <www.daifoundation.org>

interface RwaOutputConduitBaseAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function can(address) external view returns (uint256);
    function hope(address) external;
    function nope(address) external;
    function dai() external view returns (address);
    function to() external view returns (address);
    function pick(address) external;
    function push() external;
}

// https://github.com/makerdao/mip21-toolkit/blob/master/src/conduits/RwaOutputConduit.sol
interface RwaOutputConduitAbstract is RwaOutputConduitBaseAbstract {
    function gov() external view returns (address);
    function bud(address) external view returns (uint256);
    function kiss(address) external;
    function diss(address) external;
}

// https://github.com/makerdao/mip21-toolkit/blob/master/src/conduits/RwaOutputConduit2.sol
interface RwaOutputConduit2Abstract is RwaOutputConduitBaseAbstract {
    function may(address) external view returns (uint256);
    function mate(address) external;
    function hate(address) external;
}

// https://github.com/makerdao/mip21-toolkit/blob/master/src/conduits/RwaOutputConduit3.sol
interface RwaOutputConduit3Abstract is RwaOutputConduitBaseAbstract {
    function bud(address) external view returns (uint256);
    function kiss(address) external;
    function diss(address) external;
    function may(address) external view returns (uint256);
    function mate(address) external;
    function hate(address) external;
    function psm() external view returns (address);
    function gem() external view returns (address);
    function quitTo() external view returns (address);
    function file(bytes32, address) external;
    function push(uint) external;
    function quit() external;
    function quit(uint) external;
    function yank(address, address, uint256) external;
    function expectedGemAmt(uint256) external view returns (uint256);
    function requiredDaiWad(uint256) external view returns (uint256);
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/mip21/RwaUrnAbstract.sol
// SPDX-FileCopyrightText: © 2022 Dai Foundation <www.daifoundation.org>

// https://github.com/makerdao/mip21-toolkit/blob/master/src/urns/RwaUrn.sol
// https://github.com/makerdao/mip21-toolkit/blob/master/src/urns/RwaUrn2.sol
interface RwaUrnAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function can(address) external view returns (uint256);
    function hope(address) external;
    function nope(address) external;
    function vat() external view returns (address);
    function jug() external view returns (address);
    function gemJoin() external view returns (address);
    function daiJoin() external view returns (address);
    function outputConduit() external view returns (address);
    function file(bytes32, address) external;
    function lock(uint256) external;
    function draw(uint256) external;
    function wipe(uint256) external;
    function free(uint256) external;
    function quit() external;
}

// lib/sdai/deploy/SUsdsInstance.sol
// SPDX-FileCopyrightText: © 2023 Dai Foundation <www.daifoundation.org>

//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

struct SUsdsInstance {
    address sUsds;
    address sUsdsImp;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/sai/SaiMomAbstract.sol

// https://github.com/makerdao/sai/blob/master/src/mom.sol
interface SaiMomAbstract {
    function tub() external view returns (address);
    function tap() external view returns (address);
    function vox() external view returns (address);
    function setCap(uint256) external;
    function setMat(uint256) external;
    function setTax(uint256) external;
    function setFee(uint256) external;
    function setAxe(uint256) external;
    function setTubGap(uint256) external;
    function setPip(address) external;
    function setPep(address) external;
    function setVox(address) external;
    function setTapGap(uint256) external;
    function setWay(uint256) external;
    function setHow(uint256) external;
    function authority() external view returns (address);
    function owner() external view returns (address);
    function setOwner(address) external;
    function setAuthority(address) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/sai/SaiTapAbstract.sol

// https://github.com/makerdao/sai/blob/master/src/tap.sol
interface SaiTapAbstract {
    function sai() external view returns (address);
    function sin() external view returns (address);
    function skr() external view returns (address);
    function vox() external view returns (address);
    function tub() external view returns (address);
    function gap() external view returns (uint256);
    function off() external view returns (bool);
    function fix() external view returns (uint256);
    function joy() external view returns (uint256);
    function woe() external view returns (uint256);
    function fog() external view returns (uint256);
    function mold(bytes32, uint256) external;
    function heal() external;
    function s2s() external returns (uint256);
    function bid(uint256) external returns (uint256);
    function ask(uint256) external returns (uint256);
    function bust(uint256) external;
    function boom(uint256) external;
    function cage(uint256) external;
    function cash(uint256) external;
    function mock(uint256) external;
    function vent() external;
    function authority() external view returns (address);
    function owner() external view returns (address);
    function setOwner(address) external;
    function setAuthority(address) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/sai/SaiTopAbstract.sol

// https://github.com/makerdao/sai/blob/master/src/top.sol
interface SaiTopAbstract {
    function vox() external view returns (address);
    function tub() external view returns (address);
    function tap() external view returns (address);
    function sai() external view returns (address);
    function sin() external view returns (address);
    function skr() external view returns (address);
    function gem() external view returns (address);
    function fix() external view returns (uint256);
    function fit() external view returns (uint256);
    function caged() external view returns (uint256);
    function cooldown() external view returns (uint256);
    function era() external view returns (uint256);
    function cage() external;
    function flow() external;
    function setCooldown(uint256) external;
    function authority() external view returns (address);
    function owner() external view returns (address);
    function setOwner(address) external;
    function setAuthority(address) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/sai/SaiTubAbstract.sol

// https://github.com/makerdao/sai/blob/master/src/tub.sol
interface SaiTubAbstract {
    function sai() external view returns (address);
    function sin() external view returns (address);
    function skr() external view returns (address);
    function gem() external view returns (address);
    function gov() external view returns (address);
    function vox() external view returns (address);
    function pip() external view returns (address);
    function pep() external view returns (address);
    function tap() external view returns (address);
    function pit() external view returns (address);
    function axe() external view returns (uint256);
    function cap() external view returns (uint256);
    function mat() external view returns (uint256);
    function tax() external view returns (uint256);
    function fee() external view returns (uint256);
    function gap() external view returns (uint256);
    function off() external view returns (bool);
    function out() external view returns (bool);
    function fit() external view returns (uint256);
    function rho() external view returns (uint256);
    function rum() external view returns (uint256);
    function cupi() external view returns (uint256);
    function cups(bytes32) external view returns (address, uint256, uint256, uint256);
    function lad(bytes32) external view returns (address);
    function ink(bytes32) external view returns (address);
    function tab(bytes32) external view returns (uint256);
    function rap(bytes32) external returns (uint256);
    function din() external returns (uint256);
    function air() external view returns (uint256);
    function pie() external view returns (uint256);
    function era() external view returns (uint256);
    function mold(bytes32, uint256) external;
    function setPip(address) external;
    function setPep(address) external;
    function setVox(address) external;
    function turn(address) external;
    function per() external view returns (uint256);
    function ask(uint256) external view returns (uint256);
    function bid(uint256) external view returns (uint256);
    function join(uint256) external;
    function exit(uint256) external;
    function chi() external returns (uint256);
    function rhi() external returns (uint256);
    function drip() external;
    function tag() external view returns (uint256);
    function safe(bytes32) external returns (bool);
    function open() external returns (bytes32);
    function give(bytes32, address) external;
    function lock(bytes32, uint256) external;
    function free(bytes32, uint256) external;
    function draw(bytes32, uint256) external;
    function wipe(bytes32, uint256) external;
    function shut(bytes32) external;
    function bite(bytes32) external;
    function cage(uint256, uint256) external;
    function flow() external;
    function authority() external view returns (address);
    function owner() external view returns (address);
    function setOwner(address) external;
    function setAuthority(address) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/sai/SaiVoxAbstract.sol

// https://github.com/makerdao/sai/blob/master/src/vox.sol
interface SaiVoxAbstract {
    function fix() external view returns (uint256);
    function how() external view returns (uint256);
    function tau() external view returns (uint256);
    function era() external view returns (uint256);
    function mold(bytes32, uint256) external;
    function par() external returns (uint256);
    function way() external returns (uint256);
    function tell(uint256) external;
    function tune(uint256) external;
    function prod() external;
    function authority() external view returns (address);
    function owner() external view returns (address);
    function setOwner(address) external;
    function setAuthority(address) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/SpotAbstract.sol

// https://github.com/makerdao/dss/blob/master/src/spot.sol
interface SpotAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function ilks(bytes32) external view returns (address, uint256);
    function vat() external view returns (address);
    function par() external view returns (uint256);
    function live() external view returns (uint256);
    function file(bytes32, bytes32, address) external;
    function file(bytes32, uint256) external;
    function file(bytes32, bytes32, uint256) external;
    function poke(bytes32) external;
    function cage() external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/StairstepExponentialDecreaseAbstract.sol

/// StairstepExponentialDecreaseAbstract.sol -- StairstepExponentialDecrease Interface

// Copyright (C) 2021 Maker Ecosystem Growth Holdings, INC.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

interface StairstepExponentialDecreaseAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function step() external view returns (uint256);
    function cut() external view returns (uint256);
    function file(bytes32,uint256) external;
    function price(uint256,uint256) external view returns (uint256);
}

// node_modules/@openzeppelin/contracts/utils/StorageSlot.sol

// OpenZeppelin Contracts (last updated v5.1.0) (utils/StorageSlot.sol)
// This file was procedurally generated from scripts/generate/templates/StorageSlot.js.

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC-1967 implementation slot:
 * ```solidity
 * contract ERC1967 {
 *     // Define the slot. Alternatively, use the SlotDerivation library to derive the slot.
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(newImplementation.code.length > 0);
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * TIP: Consider using this library along with {SlotDerivation}.
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    struct Int256Slot {
        int256 value;
    }

    struct StringSlot {
        string value;
    }

    struct BytesSlot {
        bytes value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `Int256Slot` with member `value` located at `slot`.
     */
    function getInt256Slot(bytes32 slot) internal pure returns (Int256Slot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `StringSlot` with member `value` located at `slot`.
     */
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` representation of the string storage pointer `store`.
     */
    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        assembly ("memory-safe") {
            r.slot := store.slot
        }
    }

    /**
     * @dev Returns a `BytesSlot` with member `value` located at `slot`.
     */
    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` representation of the bytes storage pointer `store`.
     */
    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        assembly ("memory-safe") {
            r.slot := store.slot
        }
    }
}

// lib/usds/deploy/UsdsInstance.sol
// SPDX-FileCopyrightText: © 2023 Dai Foundation <www.daifoundation.org>

//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

struct UsdsInstance {
    address usds;
    address usdsImp;
    address usdsJoin;
    address daiUsds;
}

struct UsdsL2Instance {
    address usds;
    address usdsImp;
}

// lib/usds/src/UsdsJoin.sol

/// UsdsJoin.sol -- Usds adapter

// Copyright (C) 2018 Rain <rainbreak@riseup.net>
// Copyright (C) 2023 Dai Foundation
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

interface UsdsLike {
    function burn(address,uint256) external;
    function mint(address,uint256) external;
}

interface VatLike_1 {
    function move(address,address,uint256) external;
}

contract UsdsJoin {
    VatLike_1  public immutable vat;  // CDP Engine
    UsdsLike public immutable usds; // Stablecoin Token

    uint256 constant RAY = 10 ** 27;

    // --- Events ---
    event Join(address indexed caller, address indexed usr, uint256 wad);
    event Exit(address indexed caller, address indexed usr, uint256 wad);

    constructor(address vat_, address usds_) {
        vat  = VatLike_1(vat_);
        usds = UsdsLike(usds_);
    }

    function join(address usr, uint256 wad) external {
        vat.move(address(this), usr, RAY * wad);
        usds.burn(msg.sender, wad);
        emit Join(msg.sender, usr, wad);
    }

    function exit(address usr, uint256 wad) external {
        vat.move(msg.sender, address(this), RAY * wad);
        usds.mint(usr, wad);
        emit Exit(msg.sender, usr, wad);
    }

    // To fully cover daiJoin abi
    function dai() external view returns (address) {
        return address(usds);
    }
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/VatAbstract.sol

// https://github.com/makerdao/dss/blob/master/src/vat.sol
interface VatAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function can(address, address) external view returns (uint256);
    function hope(address) external;
    function nope(address) external;
    function ilks(bytes32) external view returns (uint256, uint256, uint256, uint256, uint256);
    function urns(bytes32, address) external view returns (uint256, uint256);
    function gem(bytes32, address) external view returns (uint256);
    function dai(address) external view returns (uint256);
    function sin(address) external view returns (uint256);
    function debt() external view returns (uint256);
    function vice() external view returns (uint256);
    function Line() external view returns (uint256);
    function live() external view returns (uint256);
    function init(bytes32) external;
    function file(bytes32, uint256) external;
    function file(bytes32, bytes32, uint256) external;
    function cage() external;
    function slip(bytes32, address, int256) external;
    function flux(bytes32, address, address, uint256) external;
    function move(address, address, uint256) external;
    function frob(bytes32, address, address, address, int256, int256) external;
    function fork(bytes32, address, address, int256, int256) external;
    function grab(bytes32, address, address, address, int256, int256) external;
    function heal(uint256) external;
    function suck(address, address, uint256) external;
    function fold(bytes32, address, int256) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/VestAbstract.sol

// https://github.com/makerdao/dss-vest/blob/master/src/DssVest.sol
interface VestAbstract {
    function TWENTY_YEARS() external view returns (uint256);
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function awards(uint256) external view returns (address, uint48, uint48, uint48, address, uint8, uint128, uint128);
    function ids() external view returns (uint256);
    function cap() external view returns (uint256);
    function usr(uint256) external view returns (address);
    function bgn(uint256) external view returns (uint256);
    function clf(uint256) external view returns (uint256);
    function fin(uint256) external view returns (uint256);
    function mgr(uint256) external view returns (address);
    function res(uint256) external view returns (uint256);
    function tot(uint256) external view returns (uint256);
    function rxd(uint256) external view returns (uint256);
    function file(bytes32, uint256) external;
    function create(address, uint256, uint256, uint256, uint256, address) external returns (uint256);
    function vest(uint256) external;
    function vest(uint256, uint256) external;
    function accrued(uint256) external view returns (uint256);
    function unpaid(uint256) external view returns (uint256);
    function restrict(uint256) external;
    function unrestrict(uint256) external;
    function yank(uint256) external;
    function yank(uint256, uint256) external;
    function move(uint256, address) external;
    function valid(uint256) external view returns (bool);
}

// lib/forge-std/src/Vm.sol
// Automatically @generated by scripts/vm.py. Do not modify manually.

/// The `VmSafe` interface does not allow manipulation of the EVM state or other actions that may
/// result in Script simulations differing from on-chain execution. It is recommended to only use
/// these cheats in scripts.
interface VmSafe {
    /// A modification applied to either `msg.sender` or `tx.origin`. Returned by `readCallers`.
    enum CallerMode {
        // No caller modification is currently active.
        None,
        // A one time broadcast triggered by a `vm.broadcast()` call is currently active.
        Broadcast,
        // A recurrent broadcast triggered by a `vm.startBroadcast()` call is currently active.
        RecurrentBroadcast,
        // A one time prank triggered by a `vm.prank()` call is currently active.
        Prank,
        // A recurrent prank triggered by a `vm.startPrank()` call is currently active.
        RecurrentPrank
    }

    /// The kind of account access that occurred.
    enum AccountAccessKind {
        // The account was called.
        Call,
        // The account was called via delegatecall.
        DelegateCall,
        // The account was called via callcode.
        CallCode,
        // The account was called via staticcall.
        StaticCall,
        // The account was created.
        Create,
        // The account was selfdestructed.
        SelfDestruct,
        // Synthetic access indicating the current context has resumed after a previous sub-context (AccountAccess).
        Resume,
        // The account's balance was read.
        Balance,
        // The account's codesize was read.
        Extcodesize,
        // The account's codehash was read.
        Extcodehash,
        // The account's code was copied.
        Extcodecopy
    }

    /// Forge execution contexts.
    enum ForgeContext {
        // Test group execution context (test, coverage or snapshot).
        TestGroup,
        // `forge test` execution context.
        Test,
        // `forge coverage` execution context.
        Coverage,
        // `forge snapshot` execution context.
        Snapshot,
        // Script group execution context (dry run, broadcast or resume).
        ScriptGroup,
        // `forge script` execution context.
        ScriptDryRun,
        // `forge script --broadcast` execution context.
        ScriptBroadcast,
        // `forge script --resume` execution context.
        ScriptResume,
        // Unknown `forge` execution context.
        Unknown
    }

    /// The transaction type (`txType`) of the broadcast.
    enum BroadcastTxType {
        // Represents a CALL broadcast tx.
        Call,
        // Represents a CREATE broadcast tx.
        Create,
        // Represents a CREATE2 broadcast tx.
        Create2
    }

    /// An Ethereum log. Returned by `getRecordedLogs`.
    struct Log {
        // The topics of the log, including the signature, if any.
        bytes32[] topics;
        // The raw data of the log.
        bytes data;
        // The address of the log's emitter.
        address emitter;
    }

    /// An RPC URL and its alias. Returned by `rpcUrlStructs`.
    struct Rpc {
        // The alias of the RPC URL.
        string key;
        // The RPC URL.
        string url;
    }

    /// An RPC log object. Returned by `eth_getLogs`.
    struct EthGetLogs {
        // The address of the log's emitter.
        address emitter;
        // The topics of the log, including the signature, if any.
        bytes32[] topics;
        // The raw data of the log.
        bytes data;
        // The block hash.
        bytes32 blockHash;
        // The block number.
        uint64 blockNumber;
        // The transaction hash.
        bytes32 transactionHash;
        // The transaction index in the block.
        uint64 transactionIndex;
        // The log index.
        uint256 logIndex;
        // Whether the log was removed.
        bool removed;
    }

    /// A single entry in a directory listing. Returned by `readDir`.
    struct DirEntry {
        // The error message, if any.
        string errorMessage;
        // The path of the entry.
        string path;
        // The depth of the entry.
        uint64 depth;
        // Whether the entry is a directory.
        bool isDir;
        // Whether the entry is a symlink.
        bool isSymlink;
    }

    /// Metadata information about a file.
    /// This structure is returned from the `fsMetadata` function and represents known
    /// metadata about a file such as its permissions, size, modification
    /// times, etc.
    struct FsMetadata {
        // True if this metadata is for a directory.
        bool isDir;
        // True if this metadata is for a symlink.
        bool isSymlink;
        // The size of the file, in bytes, this metadata is for.
        uint256 length;
        // True if this metadata is for a readonly (unwritable) file.
        bool readOnly;
        // The last modification time listed in this metadata.
        uint256 modified;
        // The last access time of this metadata.
        uint256 accessed;
        // The creation time listed in this metadata.
        uint256 created;
    }

    /// A wallet with a public and private key.
    struct Wallet {
        // The wallet's address.
        address addr;
        // The wallet's public key `X`.
        uint256 publicKeyX;
        // The wallet's public key `Y`.
        uint256 publicKeyY;
        // The wallet's private key.
        uint256 privateKey;
    }

    /// The result of a `tryFfi` call.
    struct FfiResult {
        // The exit code of the call.
        int32 exitCode;
        // The optionally hex-decoded `stdout` data.
        bytes stdout;
        // The `stderr` data.
        bytes stderr;
    }

    /// Information on the chain and fork.
    struct ChainInfo {
        // The fork identifier. Set to zero if no fork is active.
        uint256 forkId;
        // The chain ID of the current fork.
        uint256 chainId;
    }

    /// Information about a blockchain.
    struct Chain {
        // The chain name.
        string name;
        // The chain's Chain ID.
        uint256 chainId;
        // The chain's alias. (i.e. what gets specified in `foundry.toml`).
        string chainAlias;
        // A default RPC endpoint for this chain.
        string rpcUrl;
    }

    /// The result of a `stopAndReturnStateDiff` call.
    struct AccountAccess {
        // The chain and fork the access occurred.
        ChainInfo chainInfo;
        // The kind of account access that determines what the account is.
        // If kind is Call, DelegateCall, StaticCall or CallCode, then the account is the callee.
        // If kind is Create, then the account is the newly created account.
        // If kind is SelfDestruct, then the account is the selfdestruct recipient.
        // If kind is a Resume, then account represents a account context that has resumed.
        AccountAccessKind kind;
        // The account that was accessed.
        // It's either the account created, callee or a selfdestruct recipient for CREATE, CALL or SELFDESTRUCT.
        address account;
        // What accessed the account.
        address accessor;
        // If the account was initialized or empty prior to the access.
        // An account is considered initialized if it has code, a
        // non-zero nonce, or a non-zero balance.
        bool initialized;
        // The previous balance of the accessed account.
        uint256 oldBalance;
        // The potential new balance of the accessed account.
        // That is, all balance changes are recorded here, even if reverts occurred.
        uint256 newBalance;
        // Code of the account deployed by CREATE.
        bytes deployedCode;
        // Value passed along with the account access
        uint256 value;
        // Input data provided to the CREATE or CALL
        bytes data;
        // If this access reverted in either the current or parent context.
        bool reverted;
        // An ordered list of storage accesses made during an account access operation.
        StorageAccess[] storageAccesses;
        // Call depth traversed during the recording of state differences
        uint64 depth;
        // The previous nonce of the accessed account.
        uint64 oldNonce;
        // The new nonce of the accessed account.
        uint64 newNonce;
    }

    /// The storage accessed during an `AccountAccess`.
    struct StorageAccess {
        // The account whose storage was accessed.
        address account;
        // The slot that was accessed.
        bytes32 slot;
        // If the access was a write.
        bool isWrite;
        // The previous value of the slot.
        bytes32 previousValue;
        // The new value of the slot.
        bytes32 newValue;
        // If the access was reverted.
        bool reverted;
    }

    /// Gas used. Returned by `lastCallGas` and `lastFrameGas`.
    struct Gas {
        // The gas limit of the call.
        uint64 gasLimit;
        // The total gas used.
        uint64 gasTotalUsed;
        // DEPRECATED: The amount of gas used for memory expansion. Ref: <https://github.com/foundry-rs/foundry/pull/7934#pullrequestreview-2069236939>
        uint64 gasMemoryUsed;
        // The amount of gas refunded.
        int64 gasRefunded;
        // The amount of gas remaining.
        uint64 gasRemaining;
    }

    /// The result of the `stopDebugTraceRecording` call
    struct DebugStep {
        // The stack before executing the step of the run.
        // stack\[0\] represents the top of the stack.
        // and only stack data relevant to the opcode execution is contained.
        uint256[] stack;
        // The memory input data before executing the step of the run.
        // only input data relevant to the opcode execution is contained.
        // e.g. for MLOAD, it will have memory\[offset:offset+32\] copied here.
        // the offset value can be get by the stack data.
        bytes memoryInput;
        // The opcode that was accessed.
        uint8 opcode;
        // The call depth of the step.
        uint64 depth;
        // Whether the call end up with out of gas error.
        bool isOutOfGas;
        // The contract address where the opcode is running
        address contractAddr;
    }

    /// Represents a transaction's broadcast details.
    struct BroadcastTxSummary {
        // The hash of the transaction that was broadcasted
        bytes32 txHash;
        // Represent the type of transaction among CALL, CREATE, CREATE2
        BroadcastTxType txType;
        // The address of the contract that was called or created.
        // This is address of the contract that is created if the txType is CREATE or CREATE2.
        address contractAddress;
        // The block number the transaction landed in.
        uint64 blockNumber;
        // Status of the transaction, retrieved from the transaction receipt.
        bool success;
    }

    /// Holds a signed EIP-7702 authorization for an authority account to delegate to an implementation.
    struct SignedDelegation {
        // The y-parity of the recovered secp256k1 signature (0 or 1).
        uint8 v;
        // First 32 bytes of the signature.
        bytes32 r;
        // Second 32 bytes of the signature.
        bytes32 s;
        // The current nonce of the authority account at signing time.
        // Used to ensure signature can't be replayed after account nonce changes.
        uint64 nonce;
        // Address of the contract implementation that will be delegated to.
        // Gets encoded into delegation code: 0xef0100 || implementation.
        address implementation;
    }

    /// Represents a "potential" revert reason from a single subsequent call when using `vm.assumeNoReverts`.
    /// Reverts that match will result in a FOUNDRY::ASSUME rejection, whereas unmatched reverts will be surfaced
    /// as normal.
    struct PotentialRevert {
        // The allowed origin of the revert opcode; address(0) allows reverts from any address
        address reverter;
        // When true, only matches on the beginning of the revert data, otherwise, matches on entire revert data
        bool partialMatch;
        // The data to use to match encountered reverts
        bytes revertData;
    }

    /// An EIP-2930 access list item.
    struct AccessListItem {
        // The address to be added in access list.
        address target;
        // The storage keys to be added in access list.
        bytes32[] storageKeys;
    }

    // ======== Crypto ========

    /// Generates an Ed25519 key pair from a deterministic salt.
    /// Returns (publicKey, privateKey) as 32-byte values.
    function createEd25519Key(bytes32 salt) external pure returns (bytes32 publicKey, bytes32 privateKey);

    /// Derives a private key from the name, labels the account with that name, and returns the wallet.
    function createWallet(string calldata walletLabel) external returns (Wallet memory wallet);

    /// Generates a wallet from the private key and returns the wallet.
    function createWallet(uint256 privateKey) external returns (Wallet memory wallet);

    /// Generates a wallet from the private key, labels the account with that name, and returns the wallet.
    function createWallet(uint256 privateKey, string calldata walletLabel) external returns (Wallet memory wallet);

    /// Derive a private key from a provided mnemonic string (or mnemonic file path)
    /// at the derivation path `m/44'/60'/0'/0/{index}`.
    function deriveKey(string calldata mnemonic, uint32 index) external pure returns (uint256 privateKey);

    /// Derive a private key from a provided mnemonic string (or mnemonic file path)
    /// at `{derivationPath}{index}`.
    function deriveKey(string calldata mnemonic, string calldata derivationPath, uint32 index)
        external
        pure
        returns (uint256 privateKey);

    /// Derive a private key from a provided mnemonic string (or mnemonic file path) in the specified language
    /// at the derivation path `m/44'/60'/0'/0/{index}`.
    function deriveKey(string calldata mnemonic, uint32 index, string calldata language)
        external
        pure
        returns (uint256 privateKey);

    /// Derive a private key from a provided mnemonic string (or mnemonic file path) in the specified language
    /// at `{derivationPath}{index}`.
    function deriveKey(string calldata mnemonic, string calldata derivationPath, uint32 index, string calldata language)
        external
        pure
        returns (uint256 privateKey);

    /// Derives the Ed25519 public key from a private key.
    function publicKeyEd25519(bytes32 privateKey) external pure returns (bytes32 publicKey);

    /// Derives secp256r1 public key from the provided `privateKey`.
    function publicKeyP256(uint256 privateKey) external pure returns (uint256 publicKeyX, uint256 publicKeyY);

    /// Adds a private key to the local forge wallet and returns the address.
    function rememberKey(uint256 privateKey) external returns (address keyAddr);

    /// Derive a set number of wallets from a mnemonic at the derivation path `m/44'/60'/0'/0/{0..count}`.
    /// The respective private keys are saved to the local forge wallet for later use and their addresses are returned.
    function rememberKeys(string calldata mnemonic, string calldata derivationPath, uint32 count)
        external
        returns (address[] memory keyAddrs);

    /// Derive a set number of wallets from a mnemonic in the specified language at the derivation path `m/44'/60'/0'/0/{0..count}`.
    /// The respective private keys are saved to the local forge wallet for later use and their addresses are returned.
    function rememberKeys(
        string calldata mnemonic,
        string calldata derivationPath,
        string calldata language,
        uint32 count
    ) external returns (address[] memory keyAddrs);

    /// Signs data with a `Wallet`.
    /// Returns a compact signature (`r`, `vs`) as per EIP-2098, where `vs` encodes both the
    /// signature's `s` value, and the recovery id `v` in a single bytes32.
    /// This format reduces the signature size from 65 to 64 bytes.
    function signCompact(Wallet calldata wallet, bytes32 digest) external pure returns (bytes32 r, bytes32 vs);

    /// Signs `digest` with `privateKey` using the secp256k1 curve.
    /// Returns a compact signature (`r`, `vs`) as per EIP-2098, where `vs` encodes both the
    /// signature's `s` value, and the recovery id `v` in a single bytes32.
    /// This format reduces the signature size from 65 to 64 bytes.
    function signCompact(uint256 privateKey, bytes32 digest) external pure returns (bytes32 r, bytes32 vs);

    /// Signs `digest` with signer provided to script using the secp256k1 curve.
    /// Returns a compact signature (`r`, `vs`) as per EIP-2098, where `vs` encodes both the
    /// signature's `s` value, and the recovery id `v` in a single bytes32.
    /// This format reduces the signature size from 65 to 64 bytes.
    /// If `--sender` is provided, the signer with provided address is used, otherwise,
    /// if exactly one signer is provided to the script, that signer is used.
    /// Raises error if signer passed through `--sender` does not match any unlocked signers or
    /// if `--sender` is not provided and not exactly one signer is passed to the script.
    function signCompact(bytes32 digest) external pure returns (bytes32 r, bytes32 vs);

    /// Signs `digest` with signer provided to script using the secp256k1 curve.
    /// Returns a compact signature (`r`, `vs`) as per EIP-2098, where `vs` encodes both the
    /// signature's `s` value, and the recovery id `v` in a single bytes32.
    /// This format reduces the signature size from 65 to 64 bytes.
    /// Raises error if none of the signers passed into the script have provided address.
    function signCompact(address signer, bytes32 digest) external pure returns (bytes32 r, bytes32 vs);

    /// Signs a message with namespace using Ed25519.
    /// The signature covers namespace || message for domain separation.
    /// Returns a 64-byte Ed25519 signature.
    function signEd25519(bytes calldata namespace, bytes calldata message, bytes32 privateKey)
        external
        pure
        returns (bytes memory signature);

    /// Signs `digest` as a Tempo V2 keychain signature for `account` using a secp256k1 access key.
    /// Returns the encoded signature bytes accepted by `SignatureVerifier.verifyKeychain`.
    function signKeychain(uint256 privateKey, address account, bytes32 digest)
        external
        pure
        returns (bytes memory signature);

    /// Signs `digest` as a Tempo V2 keychain signature for `account` using a root or admin secp256k1 key.
    /// Returns the encoded signature bytes accepted by `SignatureVerifier.verifyKeychainAdmin`.
    /// The supplied `digest` should already be domain-separated with chain ID, contract address,
    /// and account address.
    function signKeychainAdmin(uint256 privateKey, address account, bytes32 digest)
        external
        pure
        returns (bytes memory signature);

    /// Signs `digest` with `privateKey` using the secp256r1 curve.
    function signP256(uint256 privateKey, bytes32 digest) external pure returns (bytes32 r, bytes32 s);

    /// Signs `digest` with `privateKey` on the secp256k1 curve, using the given `nonce`
    /// as the raw ephemeral k value in ECDSA (instead of deriving it deterministically).
    function signWithNonceUnsafe(uint256 privateKey, bytes32 digest, uint256 nonce)
        external
        pure
        returns (uint8 v, bytes32 r, bytes32 s);

    /// Signs data with a `Wallet`.
    function sign(Wallet calldata wallet, bytes32 digest) external pure returns (uint8 v, bytes32 r, bytes32 s);

    /// Signs `digest` with `privateKey` using the secp256k1 curve.
    function sign(uint256 privateKey, bytes32 digest) external pure returns (uint8 v, bytes32 r, bytes32 s);

    /// Signs `digest` with signer provided to script using the secp256k1 curve.
    /// If `--sender` is provided, the signer with provided address is used, otherwise,
    /// if exactly one signer is provided to the script, that signer is used.
    /// Raises error if signer passed through `--sender` does not match any unlocked signers or
    /// if `--sender` is not provided and not exactly one signer is passed to the script.
    function sign(bytes32 digest) external pure returns (uint8 v, bytes32 r, bytes32 s);

    /// Signs `digest` with signer provided to script using the secp256k1 curve.
    /// Raises error if none of the signers passed into the script have provided address.
    function sign(address signer, bytes32 digest) external pure returns (uint8 v, bytes32 r, bytes32 s);

    /// Verifies an Ed25519 signature over namespace || message.
    /// Returns true if signature is valid, false otherwise.
    function verifyEd25519(
        bytes calldata signature,
        bytes calldata namespace,
        bytes calldata message,
        bytes32 publicKey
    ) external pure returns (bool valid);

    // ======== Environment ========

    /// Gets the environment variable `name` and parses it as `address`.
    /// Reverts if the variable was not found or could not be parsed.
    function envAddress(string calldata name) external view returns (address value);

    /// Gets the environment variable `name` and parses it as an array of `address`, delimited by `delim`.
    /// Reverts if the variable was not found or could not be parsed.
    function envAddress(string calldata name, string calldata delim) external view returns (address[] memory value);

    /// Gets the environment variable `name` and parses it as `bool`.
    /// Reverts if the variable was not found or could not be parsed.
    function envBool(string calldata name) external view returns (bool value);

    /// Gets the environment variable `name` and parses it as an array of `bool`, delimited by `delim`.
    /// Reverts if the variable was not found or could not be parsed.
    function envBool(string calldata name, string calldata delim) external view returns (bool[] memory value);

    /// Gets the environment variable `name` and parses it as `bytes32`.
    /// Reverts if the variable was not found or could not be parsed.
    function envBytes32(string calldata name) external view returns (bytes32 value);

    /// Gets the environment variable `name` and parses it as an array of `bytes32`, delimited by `delim`.
    /// Reverts if the variable was not found or could not be parsed.
    function envBytes32(string calldata name, string calldata delim) external view returns (bytes32[] memory value);

    /// Gets the environment variable `name` and parses it as `bytes`.
    /// Reverts if the variable was not found or could not be parsed.
    function envBytes(string calldata name) external view returns (bytes memory value);

    /// Gets the environment variable `name` and parses it as an array of `bytes`, delimited by `delim`.
    /// Reverts if the variable was not found or could not be parsed.
    function envBytes(string calldata name, string calldata delim) external view returns (bytes[] memory value);

    /// Gets the environment variable `name` and returns true if it exists, else returns false.
    function envExists(string calldata name) external view returns (bool result);

    /// Gets the environment variable `name` and parses it as `int256`.
    /// Reverts if the variable was not found or could not be parsed.
    function envInt(string calldata name) external view returns (int256 value);

    /// Gets the environment variable `name` and parses it as an array of `int256`, delimited by `delim`.
    /// Reverts if the variable was not found or could not be parsed.
    function envInt(string calldata name, string calldata delim) external view returns (int256[] memory value);

    /// Gets the environment variable `name` and parses it as `bool`.
    /// Reverts if the variable could not be parsed.
    /// Returns `defaultValue` if the variable was not found.
    function envOr(string calldata name, bool defaultValue) external view returns (bool value);

    /// Gets the environment variable `name` and parses it as `uint256`.
    /// Reverts if the variable could not be parsed.
    /// Returns `defaultValue` if the variable was not found.
    function envOr(string calldata name, uint256 defaultValue) external view returns (uint256 value);

    /// Gets the environment variable `name` and parses it as an array of `address`, delimited by `delim`.
    /// Reverts if the variable could not be parsed.
    /// Returns `defaultValue` if the variable was not found.
    function envOr(string calldata name, string calldata delim, address[] calldata defaultValue)
        external
        view
        returns (address[] memory value);

    /// Gets the environment variable `name` and parses it as an array of `bytes32`, delimited by `delim`.
    /// Reverts if the variable could not be parsed.
    /// Returns `defaultValue` if the variable was not found.
    function envOr(string calldata name, string calldata delim, bytes32[] calldata defaultValue)
        external
        view
        returns (bytes32[] memory value);

    /// Gets the environment variable `name` and parses it as an array of `string`, delimited by `delim`.
    /// Reverts if the variable could not be parsed.
    /// Returns `defaultValue` if the variable was not found.
    function envOr(string calldata name, string calldata delim, string[] calldata defaultValue)
        external
        view
        returns (string[] memory value);

    /// Gets the environment variable `name` and parses it as an array of `bytes`, delimited by `delim`.
    /// Reverts if the variable could not be parsed.
    /// Returns `defaultValue` if the variable was not found.
    function envOr(string calldata name, string calldata delim, bytes[] calldata defaultValue)
        external
        view
        returns (bytes[] memory value);

    /// Gets the environment variable `name` and parses it as `int256`.
    /// Reverts if the variable could not be parsed.
    /// Returns `defaultValue` if the variable was not found.
    function envOr(string calldata name, int256 defaultValue) external view returns (int256 value);

    /// Gets the environment variable `name` and parses it as `address`.
    /// Reverts if the variable could not be parsed.
    /// Returns `defaultValue` if the variable was not found.
    function envOr(string calldata name, address defaultValue) external view returns (address value);

    /// Gets the environment variable `name` and parses it as `bytes32`.
    /// Reverts if the variable could not be parsed.
    /// Returns `defaultValue` if the variable was not found.
    function envOr(string calldata name, bytes32 defaultValue) external view returns (bytes32 value);

    /// Gets the environment variable `name` and parses it as `string`.
    /// Reverts if the variable could not be parsed.
    /// Returns `defaultValue` if the variable was not found.
    function envOr(string calldata name, string calldata defaultValue) external view returns (string memory value);

    /// Gets the environment variable `name` and parses it as `bytes`.
    /// Reverts if the variable could not be parsed.
    /// Returns `defaultValue` if the variable was not found.
    function envOr(string calldata name, bytes calldata defaultValue) external view returns (bytes memory value);

    /// Gets the environment variable `name` and parses it as an array of `bool`, delimited by `delim`.
    /// Reverts if the variable could not be parsed.
    /// Returns `defaultValue` if the variable was not found.
    function envOr(string calldata name, string calldata delim, bool[] calldata defaultValue)
        external
        view
        returns (bool[] memory value);

    /// Gets the environment variable `name` and parses it as an array of `uint256`, delimited by `delim`.
    /// Reverts if the variable could not be parsed.
    /// Returns `defaultValue` if the variable was not found.
    function envOr(string calldata name, string calldata delim, uint256[] calldata defaultValue)
        external
        view
        returns (uint256[] memory value);

    /// Gets the environment variable `name` and parses it as an array of `int256`, delimited by `delim`.
    /// Reverts if the variable could not be parsed.
    /// Returns `defaultValue` if the variable was not found.
    function envOr(string calldata name, string calldata delim, int256[] calldata defaultValue)
        external
        view
        returns (int256[] memory value);

    /// Gets the environment variable `name` and parses it as `string`.
    /// Reverts if the variable was not found or could not be parsed.
    function envString(string calldata name) external view returns (string memory value);

    /// Gets the environment variable `name` and parses it as an array of `string`, delimited by `delim`.
    /// Reverts if the variable was not found or could not be parsed.
    function envString(string calldata name, string calldata delim) external view returns (string[] memory value);

    /// Gets the environment variable `name` and parses it as `uint256`.
    /// Reverts if the variable was not found or could not be parsed.
    function envUint(string calldata name) external view returns (uint256 value);

    /// Gets the environment variable `name` and parses it as an array of `uint256`, delimited by `delim`.
    /// Reverts if the variable was not found or could not be parsed.
    function envUint(string calldata name, string calldata delim) external view returns (uint256[] memory value);

    /// Returns true if `forge` command was executed in given context.
    function isContext(ForgeContext context) external view returns (bool result);

    /// Resolves the env variable placeholders of a given input string.
    function resolveEnv(string calldata input) external returns (string memory);

    /// Sets environment variables.
    function setEnv(string calldata name, string calldata value) external;

    // ======== EVM ========

    /// Gets all accessed reads and write slot from a `vm.record` session, for a given address.
    function accesses(address target) external view returns (bytes32[] memory readSlots, bytes32[] memory writeSlots);

    /// Gets the address for a given private key.
    function addr(uint256 privateKey) external pure returns (address keyAddr);

    /// Gets all the logs according to specified filter.
    function eth_getLogs(uint256 fromBlock, uint256 toBlock, address target, bytes32[] calldata topics)
        external
        view
        returns (EthGetLogs[] memory logs);

    /// Gets the current `block.blobbasefee`.
    /// You should use this instead of `block.blobbasefee` if you use `vm.blobBaseFee`, as `block.blobbasefee` is assumed to be constant across a transaction,
    /// and as a result will get optimized out by the compiler.
    /// See https://github.com/foundry-rs/foundry/issues/6180
    function getBlobBaseFee() external view returns (uint256 blobBaseFee);

    /// Gets the current `block.number`.
    /// You should use this instead of `block.number` if you use `vm.roll`, as `block.number` is assumed to be constant across a transaction,
    /// and as a result will get optimized out by the compiler.
    /// See https://github.com/foundry-rs/foundry/issues/6180
    function getBlockNumber() external view returns (uint256 height);

    /// Gets the current `block.timestamp`.
    /// You should use this instead of `block.timestamp` if you use `vm.warp`, as `block.timestamp` is assumed to be constant across a transaction,
    /// and as a result will get optimized out by the compiler.
    /// See https://github.com/foundry-rs/foundry/issues/6180
    function getBlockTimestamp() external view returns (uint256 timestamp);

    /// Gets the current `block.chainid` of the currently selected environment.
    /// You should use this instead of `block.chainid` if you use `vm.selectFork` or `vm.createSelectFork`, as `block.chainid` could be assumed
    /// to be constant across a transaction, and as a result will get optimized out by the compiler.
    /// See https://github.com/foundry-rs/foundry/issues/6180
    function getChainId() external view returns (uint256 blockChainId);

    /// Returns the test or script execution evm version.
    /// **Note:** The execution evm version is not the same as the compilation one.
    function getEvmVersion() external pure returns (string memory evm);

    /// Gets the map key and parent of a mapping at a given slot, for a given address.
    function getMappingKeyAndParentOf(address target, bytes32 elementSlot)
        external
        view
        returns (bool found, bytes32 key, bytes32 parent);

    /// Gets the number of elements in the mapping at the given slot, for a given address.
    function getMappingLength(address target, bytes32 mappingSlot) external view returns (uint256 length);

    /// Gets the elements at index idx of the mapping at the given slot, for a given address. The
    /// index must be less than the length of the mapping (i.e. the number of keys in the mapping).
    function getMappingSlotAt(address target, bytes32 mappingSlot, uint256 idx) external view returns (bytes32 value);

    /// Gets the nonce of an account.
    function getNonce(address account) external view returns (uint64 nonce);

    /// Get the nonce of a `Wallet`.
    function getNonce(Wallet calldata wallet) external view returns (uint64 nonce);

    /// Gets the RLP encoded block header for a given block number.
    /// Returns the block header in the same format as `cast block <block_number> --raw`.
    function getRawBlockHeader(uint256 blockNumber) external view returns (bytes memory rlpHeader);

    /// Gets all the recorded logs.
    function getRecordedLogs() external view returns (Log[] memory logs);

    /// Gets all the recorded logs, in JSON format.
    function getRecordedLogsJson() external view returns (string memory logsJson);

    /// Returns state diffs from current `vm.startStateDiffRecording` session.
    function getStateDiff() external view returns (string memory diff);

    /// Returns state diffs from current `vm.startStateDiffRecording` session, in json format.
    function getStateDiffJson() external view returns (string memory diff);

    /// Returns an array of `StorageAccess` from current `vm.stateStateDiffRecording` session
    function getStorageAccesses() external view returns (StorageAccess[] memory storageAccesses);

    /// Returns an array of storage slots occupied by the specified variable.
    function getStorageSlots(address target, string calldata variableName)
        external
        view
        returns (uint256[] memory slots);

    /// Returns `true` if `spender` is on the active Tempo hardfork's implicit-approval list,
    /// meaning it can pull TIP-20 tokens from `msg.sender` without a prior `approve()`.
    /// Returns `false` on non-Tempo networks.
    function isImplicitlyApproved(address spender) external view returns (bool implicitlyApproved);

    /// Returns true if isolated test execution is enabled.
    function isIsolateMode() external view returns (bool result);

    /// Gets the gas used in the last call or create from the callee perspective.
    function lastFrameGas() external view returns (Gas memory gas);

    /// Loads a storage slot from an address.
    function load(address target, bytes32 slot) external view returns (bytes32 data);

    /// Pauses gas metering (i.e. gas usage is not counted). Noop if already paused.
    function pauseGasMetering() external;

    /// Records all storage reads and writes. Use `accesses` to get the recorded data.
    /// Subsequent calls to `record` will clear the previous data.
    function record() external;

    /// Record all the transaction logs.
    function recordLogs() external;

    /// Reset gas metering (i.e. gas usage is set to gas limit).
    function resetGasMetering() external;

    /// Resumes gas metering (i.e. gas usage is counted again). Noop if already on.
    function resumeGasMetering() external;

    /// Performs an Ethereum JSON-RPC request to the current fork URL and returns the JSON result.
    function rpcJson(string calldata method, string calldata params) external returns (string memory data);

    /// Performs an Ethereum JSON-RPC request to the given endpoint and returns the JSON result.
    function rpcJson(string calldata urlOrAlias, string calldata method, string calldata params)
        external
        returns (string memory data);

    /// Performs an Ethereum JSON-RPC request to the current fork URL.
    function rpc(string calldata method, string calldata params) external returns (bytes memory data);

    /// Performs an Ethereum JSON-RPC request to the given endpoint.
    function rpc(string calldata urlOrAlias, string calldata method, string calldata params)
        external
        returns (bytes memory data);

    /// Set the exact test or script execution evm version, e.g. `berlin`, `cancun`.
    /// **Note:** The execution evm version is not the same as the compilation one.
    function setEvmVersion(string calldata evm) external;

    /// Records the debug trace during the run.
    function startDebugTraceRecording() external;

    /// Starts recording all map SSTOREs for later retrieval.
    function startMappingRecording() external;

    /// Record all account accesses as part of CREATE, CALL or SELFDESTRUCT opcodes in order,
    /// along with the context of the calls
    function startStateDiffRecording() external;

    /// Stop debug trace recording and returns the recorded debug trace.
    function stopAndReturnDebugTraceRecording() external returns (DebugStep[] memory step);

    /// Returns an ordered array of all account accesses from a `vm.startStateDiffRecording` session.
    function stopAndReturnStateDiff() external returns (AccountAccess[] memory accountAccesses);

    /// Stops recording all map SSTOREs for later retrieval and clears the recorded data.
    function stopMappingRecording() external;

    /// Stops recording storage reads and writes.
    function stopRecord() external;

    /// DEPRECATED: use `lastFrameGas` instead.
    /// Gets the gas used in the last call from the callee perspective.
    function lastCallGas() external view returns (Gas memory gas);

    // ======== Filesystem ========

    /// Closes file for reading, resetting the offset and allowing to read it from beginning with readLine.
    /// `path` is relative to the project root.
    function closeFile(string calldata path) external;

    /// Copies the contents of one file to another. This function will **overwrite** the contents of `to`.
    /// On success, the total number of bytes copied is returned and it is equal to the length of the `to` file as reported by `metadata`.
    /// Both `from` and `to` are relative to the project root.
    function copyFile(string calldata from, string calldata to) external returns (uint64 copied);

    /// Creates a new, empty directory at the provided path.
    /// This cheatcode will revert in the following situations, but is not limited to just these cases:
    /// - User lacks permissions to modify `path`.
    /// - A parent of the given path doesn't exist and `recursive` is false.
    /// - `path` already exists and `recursive` is false.
    /// `path` is relative to the project root.
    function createDir(string calldata path, bool recursive) external;

    /// Get the source file path of the currently running test or script contract,
    /// relative to the project root.
    function currentFilePath() external view returns (string memory path);

    /// Deploys a contract from an artifact file. Takes in the relative path to the json file or the path to the
    /// artifact in the form of <path>:<contract>:<version> or <path>:<contract>:<profile> where <contract> and
    /// <version>/<profile> parts are optional.
    /// Reverts if the target artifact contains unlinked library placeholders.
    function deployCode(string calldata artifactPath) external returns (address deployedAddress);

    /// Deploys a contract from an artifact file. Takes in the relative path to the json file or the path to the
    /// artifact in the form of <path>:<contract>:<version> or <path>:<contract>:<profile> where <contract> and
    /// <version>/<profile> parts are optional.
    /// Reverts if the target artifact contains unlinked library placeholders.
    /// Additionally accepts abi-encoded constructor arguments.
    function deployCode(string calldata artifactPath, bytes calldata constructorArgs)
        external
        returns (address deployedAddress);

    /// Deploys a contract from an artifact file. Takes in the relative path to the json file or the path to the
    /// artifact in the form of <path>:<contract>:<version> or <path>:<contract>:<profile> where <contract> and
    /// <version>/<profile> parts are optional.
    /// Reverts if the target artifact contains unlinked library placeholders.
    /// Additionally accepts `msg.value`.
    function deployCode(string calldata artifactPath, uint256 value) external returns (address deployedAddress);

    /// Deploys a contract from an artifact file. Takes in the relative path to the json file or the path to the
    /// artifact in the form of <path>:<contract>:<version> or <path>:<contract>:<profile> where <contract> and
    /// <version>/<profile> parts are optional.
    /// Reverts if the target artifact contains unlinked library placeholders.
    /// Additionally accepts abi-encoded constructor arguments and `msg.value`.
    function deployCode(string calldata artifactPath, bytes calldata constructorArgs, uint256 value)
        external
        returns (address deployedAddress);

    /// Deploys a contract from an artifact file, using the CREATE2 salt. Takes in the relative path to the json file or the path to the
    /// artifact in the form of <path>:<contract>:<version> or <path>:<contract>:<profile> where <contract> and
    /// <version>/<profile> parts are optional.
    /// Reverts if the target artifact contains unlinked library placeholders.
    function deployCode(string calldata artifactPath, bytes32 salt) external returns (address deployedAddress);

    /// Deploys a contract from an artifact file, using the CREATE2 salt. Takes in the relative path to the json file or the path to the
    /// artifact in the form of <path>:<contract>:<version> or <path>:<contract>:<profile> where <contract> and
    /// <version>/<profile> parts are optional.
    /// Reverts if the target artifact contains unlinked library placeholders.
    /// Additionally accepts abi-encoded constructor arguments.
    function deployCode(string calldata artifactPath, bytes calldata constructorArgs, bytes32 salt)
        external
        returns (address deployedAddress);

    /// Deploys a contract from an artifact file, using the CREATE2 salt. Takes in the relative path to the json file or the path to the
    /// artifact in the form of <path>:<contract>:<version> or <path>:<contract>:<profile> where <contract> and
    /// <version>/<profile> parts are optional.
    /// Reverts if the target artifact contains unlinked library placeholders.
    /// Additionally accepts `msg.value`.
    function deployCode(string calldata artifactPath, uint256 value, bytes32 salt)
        external
        returns (address deployedAddress);

    /// Deploys a contract from an artifact file, using the CREATE2 salt. Takes in the relative path to the json file or the path to the
    /// artifact in the form of <path>:<contract>:<version> or <path>:<contract>:<profile> where <contract> and
    /// <version>/<profile> parts are optional.
    /// Reverts if the target artifact contains unlinked library placeholders.
    /// Additionally accepts abi-encoded constructor arguments and `msg.value`.
    function deployCode(string calldata artifactPath, bytes calldata constructorArgs, uint256 value, bytes32 salt)
        external
        returns (address deployedAddress);

    /// Returns true if the given path points to an existing entity, else returns false.
    function exists(string calldata path) external view returns (bool result);

    /// Performs a foreign function call via the terminal.
    function ffi(string[] calldata commandInput) external returns (bytes memory result);

    /// Given a path, query the file system to get information about a file, directory, etc.
    function fsMetadata(string calldata path) external view returns (FsMetadata memory metadata);

    /// Gets the artifact path from code (aka. creation code).
    function getArtifactPathByCode(bytes calldata code) external view returns (string memory path);

    /// Gets the artifact path from deployed code (aka. runtime code).
    function getArtifactPathByDeployedCode(bytes calldata deployedCode) external view returns (string memory path);

    /// Returns the most recent broadcast for the given contract on `chainId` matching `txType`.
    /// For example:
    /// The most recent deployment can be fetched by passing `txType` as `CREATE` or `CREATE2`.
    /// The most recent call can be fetched by passing `txType` as `CALL`.
    function getBroadcast(string calldata contractName, uint64 chainId, BroadcastTxType txType)
        external
        view
        returns (BroadcastTxSummary memory);

    /// Returns all broadcasts for the given contract on `chainId` with the specified `txType`.
    /// Sorted such that the most recent broadcast is the first element, and the oldest is the last. i.e descending order of BroadcastTxSummary.blockNumber.
    function getBroadcasts(string calldata contractName, uint64 chainId, BroadcastTxType txType)
        external
        view
        returns (BroadcastTxSummary[] memory);

    /// Returns all broadcasts for the given contract on `chainId`.
    /// Sorted such that the most recent broadcast is the first element, and the oldest is the last. i.e descending order of BroadcastTxSummary.blockNumber.
    function getBroadcasts(string calldata contractName, uint64 chainId)
        external
        view
        returns (BroadcastTxSummary[] memory);

    /// Gets the creation bytecode from an artifact file. Takes in the relative path to the json file or the path to the
    /// artifact in the form of <path>:<contract>:<version> or <path>:<contract>:<profile> where <contract> and
    /// <version>/<profile> parts are optional. Use <profile> to select artifacts compiled with a specific profile
    /// from foundry.toml.
    function getCode(string calldata artifactPath) external view returns (bytes memory creationBytecode);

    /// Gets the deployed bytecode from an artifact file. Takes in the relative path to the json file or the path to the
    /// artifact in the form of <path>:<contract>:<version> or <path>:<contract>:<profile> where <contract> and
    /// <version>/<profile> parts are optional.
    function getDeployedCode(string calldata artifactPath) external view returns (bytes memory runtimeBytecode);

    /// Returns the most recent deployment for the current `chainId`.
    function getDeployment(string calldata contractName) external view returns (address deployedAddress);

    /// Returns the most recent deployment for the given contract on `chainId`
    function getDeployment(string calldata contractName, uint64 chainId) external view returns (address deployedAddress);

    /// Returns all deployments for the given contract on `chainId`
    /// Sorted in descending order of deployment time i.e descending order of BroadcastTxSummary.blockNumber.
    /// The most recent deployment is the first element, and the oldest is the last.
    function getDeployments(string calldata contractName, uint64 chainId)
        external
        view
        returns (address[] memory deployedAddresses);

    /// Gets all function selectors from a contract artifact. Takes in the relative path to the json file or the path to the
    /// artifact in the form of <path>:<contract>:<version> where <contract> and <version> parts are optional.
    function getSelectors(string calldata artifactPath) external view returns (bytes4[] memory selectors);

    /// Returns true if the path exists on disk and is pointing at a directory, else returns false.
    function isDir(string calldata path) external view returns (bool result);

    /// Returns true if the path exists on disk and is pointing at a regular file, else returns false.
    function isFile(string calldata path) external view returns (bool result);

    /// Get the path of the current project root.
    function projectRoot() external view returns (string memory path);

    /// Prompts the user for a string value in the terminal.
    function prompt(string calldata promptText) external returns (string memory input);

    /// Prompts the user for an address in the terminal.
    function promptAddress(string calldata promptText) external returns (address);

    /// Prompts the user for a hidden string value in the terminal.
    function promptSecret(string calldata promptText) external returns (string memory input);

    /// Prompts the user for hidden uint256 in the terminal (usually pk).
    function promptSecretUint(string calldata promptText) external returns (uint256);

    /// Prompts the user for uint256 in the terminal.
    function promptUint(string calldata promptText) external returns (uint256);

    /// Reads the directory at the given path recursively, up to `maxDepth`.
    /// `maxDepth` defaults to 1, meaning only the direct children of the given directory will be returned.
    /// Follows symbolic links if `followLinks` is true.
    function readDir(string calldata path) external view returns (DirEntry[] memory entries);

    /// See `readDir(string)`.
    function readDir(string calldata path, uint64 maxDepth) external view returns (DirEntry[] memory entries);

    /// See `readDir(string)`.
    function readDir(string calldata path, uint64 maxDepth, bool followLinks)
        external
        view
        returns (DirEntry[] memory entries);

    /// Reads the entire content of file to string. `path` is relative to the project root.
    function readFile(string calldata path) external view returns (string memory data);

    /// Reads the entire content of file as binary. `path` is relative to the project root.
    function readFileBinary(string calldata path) external view returns (bytes memory data);

    /// Reads next line of file to string.
    function readLine(string calldata path) external view returns (string memory line);

    /// Reads a symbolic link, returning the path that the link points to.
    /// This cheatcode will revert in the following situations, but is not limited to just these cases:
    /// - `path` is not a symbolic link.
    /// - `path` does not exist.
    function readLink(string calldata linkPath) external view returns (string memory targetPath);

    /// Removes a directory at the provided path.
    /// This cheatcode will revert in the following situations, but is not limited to just these cases:
    /// - `path` doesn't exist.
    /// - `path` isn't a directory.
    /// - User lacks permissions to modify `path`.
    /// - The directory is not empty and `recursive` is false.
    /// `path` is relative to the project root.
    function removeDir(string calldata path, bool recursive) external;

    /// Removes a file from the filesystem.
    /// This cheatcode will revert in the following situations, but is not limited to just these cases:
    /// - `path` points to a directory.
    /// - The file doesn't exist.
    /// - The user lacks permissions to remove the file.
    /// `path` is relative to the project root.
    function removeFile(string calldata path) external;

    /// Performs a foreign function call via terminal and returns the exit code, stdout, and stderr.
    function tryFfi(string[] calldata commandInput) external returns (FfiResult memory result);

    /// Returns the time since unix epoch in milliseconds.
    function unixTime() external view returns (uint256 milliseconds);

    /// Writes data to file, creating a file if it does not exist, and entirely replacing its contents if it does.
    /// `path` is relative to the project root.
    function writeFile(string calldata path, string calldata data) external;

    /// Writes binary data to a file, creating a file if it does not exist, and entirely replacing its contents if it does.
    /// `path` is relative to the project root.
    function writeFileBinary(string calldata path, bytes calldata data) external;

    /// Writes line to file, creating a file if it does not exist.
    /// `path` is relative to the project root.
    function writeLine(string calldata path, string calldata data) external;

    // ======== JSON ========

    /// Checks if `key` exists in a JSON object.
    function keyExistsJson(string calldata json, string calldata key) external view returns (bool);

    /// Parses a string of JSON data at `key` and coerces it to `address`.
    function parseJsonAddress(string calldata json, string calldata key) external pure returns (address);

    /// Parses a string of JSON data at `key` and coerces it to `address[]`.
    function parseJsonAddressArray(string calldata json, string calldata key) external pure returns (address[] memory);

    /// Returns the length of the JSON array at `key`.
    function parseJsonArrayLength(string calldata json, string calldata key) external pure returns (uint256 length);

    /// Parses a string of JSON data at `key` and coerces it to `bool`.
    function parseJsonBool(string calldata json, string calldata key) external pure returns (bool);

    /// Parses a string of JSON data at `key` and coerces it to `bool[]`.
    function parseJsonBoolArray(string calldata json, string calldata key) external pure returns (bool[] memory);

    /// Parses a string of JSON data at `key` and coerces it to `bytes`.
    function parseJsonBytes(string calldata json, string calldata key) external pure returns (bytes memory);

    /// Parses a string of JSON data at `key` and coerces it to `bytes32`.
    function parseJsonBytes32(string calldata json, string calldata key) external pure returns (bytes32);

    /// Parses a string of JSON data at `key` and coerces it to `bytes32[]`.
    function parseJsonBytes32Array(string calldata json, string calldata key) external pure returns (bytes32[] memory);

    /// Parses a string of JSON data at `key` and coerces it to `bytes[]`.
    function parseJsonBytesArray(string calldata json, string calldata key) external pure returns (bytes[] memory);

    /// Parses a string of JSON data at `key` and coerces it to `int256`.
    function parseJsonInt(string calldata json, string calldata key) external pure returns (int256);

    /// Parses a string of JSON data at `key` and coerces it to `int256[]`.
    function parseJsonIntArray(string calldata json, string calldata key) external pure returns (int256[] memory);

    /// Returns an array of all the keys in a JSON object.
    function parseJsonKeys(string calldata json, string calldata key) external pure returns (string[] memory keys);

    /// Parses a string of JSON data at `key` and coerces it to `string`.
    function parseJsonString(string calldata json, string calldata key) external pure returns (string memory);

    /// Parses a string of JSON data at `key` and coerces it to `string[]`.
    function parseJsonStringArray(string calldata json, string calldata key) external pure returns (string[] memory);

    /// Parses a string of JSON data at `key` and coerces it to type array corresponding to `typeDescription`.
    function parseJsonTypeArray(string calldata json, string calldata key, string calldata typeDescription)
        external
        pure
        returns (bytes memory);

    /// Parses a string of JSON data and coerces it to type corresponding to `typeDescription`.
    function parseJsonType(string calldata json, string calldata typeDescription) external pure returns (bytes memory);

    /// Parses a string of JSON data at `key` and coerces it to type corresponding to `typeDescription`.
    function parseJsonType(string calldata json, string calldata key, string calldata typeDescription)
        external
        pure
        returns (bytes memory);

    /// Parses a string of JSON data at `key` and coerces it to `uint256`.
    function parseJsonUint(string calldata json, string calldata key) external pure returns (uint256);

    /// Parses a string of JSON data at `key` and coerces it to `uint256[]`.
    function parseJsonUintArray(string calldata json, string calldata key) external pure returns (uint256[] memory);

    /// ABI-encodes a JSON object.
    function parseJson(string calldata json) external pure returns (bytes memory abiEncodedData);

    /// ABI-encodes a JSON object at `key`.
    function parseJson(string calldata json, string calldata key) external pure returns (bytes memory abiEncodedData);

    /// See `serializeJson`.
    function serializeAddress(string calldata objectKey, string calldata valueKey, address value)
        external
        returns (string memory json);

    /// See `serializeJson`.
    function serializeAddress(string calldata objectKey, string calldata valueKey, address[] calldata values)
        external
        returns (string memory json);

    /// See `serializeJson`.
    function serializeBool(string calldata objectKey, string calldata valueKey, bool value)
        external
        returns (string memory json);

    /// See `serializeJson`.
    function serializeBool(string calldata objectKey, string calldata valueKey, bool[] calldata values)
        external
        returns (string memory json);

    /// See `serializeJson`.
    function serializeBytes32(string calldata objectKey, string calldata valueKey, bytes32 value)
        external
        returns (string memory json);

    /// See `serializeJson`.
    function serializeBytes32(string calldata objectKey, string calldata valueKey, bytes32[] calldata values)
        external
        returns (string memory json);

    /// See `serializeJson`.
    function serializeBytes(string calldata objectKey, string calldata valueKey, bytes calldata value)
        external
        returns (string memory json);

    /// See `serializeJson`.
    function serializeBytes(string calldata objectKey, string calldata valueKey, bytes[] calldata values)
        external
        returns (string memory json);

    /// See `serializeJson`.
    function serializeInt(string calldata objectKey, string calldata valueKey, int256 value)
        external
        returns (string memory json);

    /// See `serializeJson`.
    function serializeInt(string calldata objectKey, string calldata valueKey, int256[] calldata values)
        external
        returns (string memory json);

    /// Serializes a key and value to a JSON object stored in-memory that can be later written to a file.
    /// Returns the stringified version of the specific JSON file up to that moment.
    function serializeJson(string calldata objectKey, string calldata value) external returns (string memory json);

    /// See `serializeJson`.
    function serializeJsonType(string calldata typeDescription, bytes calldata value)
        external
        pure
        returns (string memory json);

    /// See `serializeJson`.
    function serializeJsonType(
        string calldata objectKey,
        string calldata valueKey,
        string calldata typeDescription,
        bytes calldata value
    ) external returns (string memory json);

    /// See `serializeJson`.
    function serializeString(string calldata objectKey, string calldata valueKey, string calldata value)
        external
        returns (string memory json);

    /// See `serializeJson`.
    function serializeString(string calldata objectKey, string calldata valueKey, string[] calldata values)
        external
        returns (string memory json);

    /// See `serializeJson`.
    function serializeUintToHex(string calldata objectKey, string calldata valueKey, uint256 value)
        external
        returns (string memory json);

    /// See `serializeJson`.
    function serializeUint(string calldata objectKey, string calldata valueKey, uint256 value)
        external
        returns (string memory json);

    /// See `serializeJson`.
    function serializeUint(string calldata objectKey, string calldata valueKey, uint256[] calldata values)
        external
        returns (string memory json);

    /// Write a serialized JSON object to a file. If the file exists, it will be overwritten.
    function writeJson(string calldata json, string calldata path) external;

    /// Write a serialized JSON object to an **existing** JSON file, replacing a value with key = <value_key.>
    /// This is useful to replace a specific value of a JSON file, without having to parse the entire thing.
    /// This cheatcode will create new keys if they didn't previously exist.
    function writeJson(string calldata json, string calldata path, string calldata valueKey) external;

    /// Checks if `key` exists in a JSON object
    /// `keyExists` is being deprecated in favor of `keyExistsJson`. It will be removed in future versions.
    function keyExists(string calldata json, string calldata key) external view returns (bool);

    // ======== Scripting ========

    /// Attach an EIP-4844 blob to the next call
    function attachBlob(bytes calldata blob) external;

    /// Designate the next call as an EIP-7702 transaction
    function attachDelegation(SignedDelegation calldata signedDelegation) external;

    /// Designate the next call as an EIP-7702 transaction, with optional cross-chain validity.
    function attachDelegation(SignedDelegation calldata signedDelegation, bool crossChain) external;

    /// Takes a signed transaction and broadcasts it to the network.
    function broadcastRawTransaction(bytes calldata data) external;

    /// Has the next call (at this call depth only) create transactions that can later be signed and sent onchain.
    /// Broadcasting address is determined by checking the following in order:
    /// 1. If `--sender` argument was provided, that address is used.
    /// 2. If exactly one signer (e.g. private key, hw wallet, keystore) is set when `forge broadcast` is invoked, that signer is used.
    /// 3. Otherwise, default foundry sender (1804c8AB1F12E6bbf3894d4083f33e07309d1f38) is used.
    function broadcast() external;

    /// Has the next call (at this call depth only) create a transaction with the address provided
    /// as the sender that can later be signed and sent onchain.
    function broadcast(address signer) external;

    /// Has the next call (at this call depth only) create a transaction with the private key
    /// provided as the sender that can later be signed and sent onchain.
    function broadcast(uint256 privateKey) external;

    /// Returns addresses of available unlocked wallets in the script environment.
    function getWallets() external view returns (address[] memory wallets);

    /// Sign an EIP-7702 authorization and designate the next call as an EIP-7702 transaction
    function signAndAttachDelegation(address implementation, uint256 privateKey)
        external
        returns (SignedDelegation memory signedDelegation);

    /// Sign an EIP-7702 authorization and designate the next call as an EIP-7702 transaction for specific nonce
    function signAndAttachDelegation(address implementation, uint256 privateKey, uint64 nonce)
        external
        returns (SignedDelegation memory signedDelegation);

    /// Sign an EIP-7702 authorization and designate the next call as an EIP-7702 transaction, with optional cross-chain validity.
    function signAndAttachDelegation(address implementation, uint256 privateKey, bool crossChain)
        external
        returns (SignedDelegation memory signedDelegation);

    /// Sign an EIP-7702 authorization for delegation
    function signDelegation(address implementation, uint256 privateKey)
        external
        returns (SignedDelegation memory signedDelegation);

    /// Sign an EIP-7702 authorization for delegation for specific nonce
    function signDelegation(address implementation, uint256 privateKey, uint64 nonce)
        external
        returns (SignedDelegation memory signedDelegation);

    /// Sign an EIP-7702 authorization for delegation, with optional cross-chain validity.
    function signDelegation(address implementation, uint256 privateKey, bool crossChain)
        external
        returns (SignedDelegation memory signedDelegation);

    /// Has all subsequent calls (at this call depth only) create transactions that can later be signed and sent onchain.
    /// Broadcasting address is determined by checking the following in order:
    /// 1. If `--sender` argument was provided, that address is used.
    /// 2. If exactly one signer (e.g. private key, hw wallet, keystore) is set when `forge broadcast` is invoked, that signer is used.
    /// 3. Otherwise, default foundry sender (1804c8AB1F12E6bbf3894d4083f33e07309d1f38) is used.
    function startBroadcast() external;

    /// Has all subsequent calls (at this call depth only) create transactions with the address
    /// provided that can later be signed and sent onchain.
    function startBroadcast(address signer) external;

    /// Has all subsequent calls (at this call depth only) create transactions with the private key
    /// provided that can later be signed and sent onchain.
    function startBroadcast(uint256 privateKey) external;

    /// Stops collecting onchain transactions.
    function stopBroadcast() external;

    // ======== String ========

    /// Returns true if `search` is found in `subject`, false otherwise.
    function contains(string calldata subject, string calldata search) external pure returns (bool result);

    /// Returns the index of the first occurrence of a `key` in an `input` string.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `key` is not found.
    /// Returns 0 in case of an empty `key`.
    function indexOf(string calldata input, string calldata key) external pure returns (uint256);

    /// Parses the given `string` into an `address`.
    function parseAddress(string calldata stringifiedValue) external pure returns (address parsedValue);

    /// Parses the given `string` into a `bool`.
    function parseBool(string calldata stringifiedValue) external pure returns (bool parsedValue);

    /// Parses the given `string` into `bytes`.
    function parseBytes(string calldata stringifiedValue) external pure returns (bytes memory parsedValue);

    /// Parses the given `string` into a `bytes32`.
    function parseBytes32(string calldata stringifiedValue) external pure returns (bytes32 parsedValue);

    /// Parses the given `string` into a `int256`.
    function parseInt(string calldata stringifiedValue) external pure returns (int256 parsedValue);

    /// Parses the given `string` into a `uint256`.
    function parseUint(string calldata stringifiedValue) external pure returns (uint256 parsedValue);

    /// Replaces occurrences of `from` in the given `string` with `to`.
    function replace(string calldata input, string calldata from, string calldata to)
        external
        pure
        returns (string memory output);

    /// Splits the given `string` into an array of strings divided by the `delimiter`.
    function split(string calldata input, string calldata delimiter) external pure returns (string[] memory outputs);

    /// Converts the given `string` value to Lowercase.
    function toLowercase(string calldata input) external pure returns (string memory output);

    /// Converts the given value to a `string`.
    function toString(address value) external pure returns (string memory stringifiedValue);

    /// Converts the given value to a `string`.
    function toString(bytes calldata value) external pure returns (string memory stringifiedValue);

    /// Converts the given value to a `string`.
    function toString(bytes32 value) external pure returns (string memory stringifiedValue);

    /// Converts the given value to a `string`.
    function toString(bool value) external pure returns (string memory stringifiedValue);

    /// Converts the given value to a `string`.
    function toString(uint256 value) external pure returns (string memory stringifiedValue);

    /// Converts the given value to a `string`.
    function toString(int256 value) external pure returns (string memory stringifiedValue);

    /// Converts the given `string` value to Uppercase.
    function toUppercase(string calldata input) external pure returns (string memory output);

    /// Trims leading and trailing whitespace from the given `string` value.
    function trim(string calldata input) external pure returns (string memory output);

    // ======== Testing ========

    /// Compares two `uint256` values. Expects difference to be less than or equal to `maxDelta`.
    /// Formats values with decimals in failure message.
    function assertApproxEqAbsDecimal(uint256 left, uint256 right, uint256 maxDelta, uint256 decimals) external pure;

    /// Compares two `uint256` values. Expects difference to be less than or equal to `maxDelta`.
    /// Formats values with decimals in failure message. Includes error message into revert string on failure.
    function assertApproxEqAbsDecimal(
        uint256 left,
        uint256 right,
        uint256 maxDelta,
        uint256 decimals,
        string calldata err
    ) external pure;

    /// Compares two `int256` values. Expects difference to be less than or equal to `maxDelta`.
    /// Formats values with decimals in failure message.
    function assertApproxEqAbsDecimal(int256 left, int256 right, uint256 maxDelta, uint256 decimals) external pure;

    /// Compares two `int256` values. Expects difference to be less than or equal to `maxDelta`.
    /// Formats values with decimals in failure message. Includes error message into revert string on failure.
    function assertApproxEqAbsDecimal(
        int256 left,
        int256 right,
        uint256 maxDelta,
        uint256 decimals,
        string calldata err
    ) external pure;

    /// Compares two `uint256` values. Expects difference to be less than or equal to `maxDelta`.
    function assertApproxEqAbs(uint256 left, uint256 right, uint256 maxDelta) external pure;

    /// Compares two `uint256` values. Expects difference to be less than or equal to `maxDelta`.
    /// Includes error message into revert string on failure.
    function assertApproxEqAbs(uint256 left, uint256 right, uint256 maxDelta, string calldata err) external pure;

    /// Compares two `int256` values. Expects difference to be less than or equal to `maxDelta`.
    function assertApproxEqAbs(int256 left, int256 right, uint256 maxDelta) external pure;

    /// Compares two `int256` values. Expects difference to be less than or equal to `maxDelta`.
    /// Includes error message into revert string on failure.
    function assertApproxEqAbs(int256 left, int256 right, uint256 maxDelta, string calldata err) external pure;

    /// Compares two `uint256` values. Expects relative difference in percents to be less than or equal to `maxPercentDelta`.
    /// `maxPercentDelta` is an 18 decimal fixed point number, where 1e18 == 100%
    /// Formats values with decimals in failure message.
    function assertApproxEqRelDecimal(uint256 left, uint256 right, uint256 maxPercentDelta, uint256 decimals)
        external
        pure;

    /// Compares two `uint256` values. Expects relative difference in percents to be less than or equal to `maxPercentDelta`.
    /// `maxPercentDelta` is an 18 decimal fixed point number, where 1e18 == 100%
    /// Formats values with decimals in failure message. Includes error message into revert string on failure.
    function assertApproxEqRelDecimal(
        uint256 left,
        uint256 right,
        uint256 maxPercentDelta,
        uint256 decimals,
        string calldata err
    ) external pure;

    /// Compares two `int256` values. Expects relative difference in percents to be less than or equal to `maxPercentDelta`.
    /// `maxPercentDelta` is an 18 decimal fixed point number, where 1e18 == 100%
    /// Formats values with decimals in failure message.
    function assertApproxEqRelDecimal(int256 left, int256 right, uint256 maxPercentDelta, uint256 decimals)
        external
        pure;

    /// Compares two `int256` values. Expects relative difference in percents to be less than or equal to `maxPercentDelta`.
    /// `maxPercentDelta` is an 18 decimal fixed point number, where 1e18 == 100%
    /// Formats values with decimals in failure message. Includes error message into revert string on failure.
    function assertApproxEqRelDecimal(
        int256 left,
        int256 right,
        uint256 maxPercentDelta,
        uint256 decimals,
        string calldata err
    ) external pure;

    /// Compares two `uint256` values. Expects relative difference in percents to be less than or equal to `maxPercentDelta`.
    /// `maxPercentDelta` is an 18 decimal fixed point number, where 1e18 == 100%
    function assertApproxEqRel(uint256 left, uint256 right, uint256 maxPercentDelta) external pure;

    /// Compares two `uint256` values. Expects relative difference in percents to be less than or equal to `maxPercentDelta`.
    /// `maxPercentDelta` is an 18 decimal fixed point number, where 1e18 == 100%
    /// Includes error message into revert string on failure.
    function assertApproxEqRel(uint256 left, uint256 right, uint256 maxPercentDelta, string calldata err) external pure;

    /// Compares two `int256` values. Expects relative difference in percents to be less than or equal to `maxPercentDelta`.
    /// `maxPercentDelta` is an 18 decimal fixed point number, where 1e18 == 100%
    function assertApproxEqRel(int256 left, int256 right, uint256 maxPercentDelta) external pure;

    /// Compares two `int256` values. Expects relative difference in percents to be less than or equal to `maxPercentDelta`.
    /// `maxPercentDelta` is an 18 decimal fixed point number, where 1e18 == 100%
    /// Includes error message into revert string on failure.
    function assertApproxEqRel(int256 left, int256 right, uint256 maxPercentDelta, string calldata err) external pure;

    /// Asserts that two `uint256` values are equal, formatting them with decimals in failure message.
    function assertEqDecimal(uint256 left, uint256 right, uint256 decimals) external pure;

    /// Asserts that two `uint256` values are equal, formatting them with decimals in failure message.
    /// Includes error message into revert string on failure.
    function assertEqDecimal(uint256 left, uint256 right, uint256 decimals, string calldata err) external pure;

    /// Asserts that two `int256` values are equal, formatting them with decimals in failure message.
    function assertEqDecimal(int256 left, int256 right, uint256 decimals) external pure;

    /// Asserts that two `int256` values are equal, formatting them with decimals in failure message.
    /// Includes error message into revert string on failure.
    function assertEqDecimal(int256 left, int256 right, uint256 decimals, string calldata err) external pure;

    /// Asserts that two `bool` values are equal.
    function assertEq(bool left, bool right) external pure;

    /// Asserts that two `bool` values are equal and includes error message into revert string on failure.
    function assertEq(bool left, bool right, string calldata err) external pure;

    /// Asserts that two `string` values are equal.
    function assertEq(string calldata left, string calldata right) external pure;

    /// Asserts that two `string` values are equal and includes error message into revert string on failure.
    function assertEq(string calldata left, string calldata right, string calldata err) external pure;

    /// Asserts that two `bytes` values are equal.
    function assertEq(bytes calldata left, bytes calldata right) external pure;

    /// Asserts that two `bytes` values are equal and includes error message into revert string on failure.
    function assertEq(bytes calldata left, bytes calldata right, string calldata err) external pure;

    /// Asserts that two arrays of `bool` values are equal.
    function assertEq(bool[] calldata left, bool[] calldata right) external pure;

    /// Asserts that two arrays of `bool` values are equal and includes error message into revert string on failure.
    function assertEq(bool[] calldata left, bool[] calldata right, string calldata err) external pure;

    /// Asserts that two arrays of `uint256 values are equal.
    function assertEq(uint256[] calldata left, uint256[] calldata right) external pure;

    /// Asserts that two arrays of `uint256` values are equal and includes error message into revert string on failure.
    function assertEq(uint256[] calldata left, uint256[] calldata right, string calldata err) external pure;

    /// Asserts that two arrays of `int256` values are equal.
    function assertEq(int256[] calldata left, int256[] calldata right) external pure;

    /// Asserts that two arrays of `int256` values are equal and includes error message into revert string on failure.
    function assertEq(int256[] calldata left, int256[] calldata right, string calldata err) external pure;

    /// Asserts that two `uint256` values are equal.
    function assertEq(uint256 left, uint256 right) external pure;

    /// Asserts that two arrays of `address` values are equal.
    function assertEq(address[] calldata left, address[] calldata right) external pure;

    /// Asserts that two arrays of `address` values are equal and includes error message into revert string on failure.
    function assertEq(address[] calldata left, address[] calldata right, string calldata err) external pure;

    /// Asserts that two arrays of `bytes32` values are equal.
    function assertEq(bytes32[] calldata left, bytes32[] calldata right) external pure;

    /// Asserts that two arrays of `bytes32` values are equal and includes error message into revert string on failure.
    function assertEq(bytes32[] calldata left, bytes32[] calldata right, string calldata err) external pure;

    /// Asserts that two arrays of `string` values are equal.
    function assertEq(string[] calldata left, string[] calldata right) external pure;

    /// Asserts that two arrays of `string` values are equal and includes error message into revert string on failure.
    function assertEq(string[] calldata left, string[] calldata right, string calldata err) external pure;

    /// Asserts that two arrays of `bytes` values are equal.
    function assertEq(bytes[] calldata left, bytes[] calldata right) external pure;

    /// Asserts that two arrays of `bytes` values are equal and includes error message into revert string on failure.
    function assertEq(bytes[] calldata left, bytes[] calldata right, string calldata err) external pure;

    /// Asserts that two `uint256` values are equal and includes error message into revert string on failure.
    function assertEq(uint256 left, uint256 right, string calldata err) external pure;

    /// Asserts that two `int256` values are equal.
    function assertEq(int256 left, int256 right) external pure;

    /// Asserts that two `int256` values are equal and includes error message into revert string on failure.
    function assertEq(int256 left, int256 right, string calldata err) external pure;

    /// Asserts that two `address` values are equal.
    function assertEq(address left, address right) external pure;

    /// Asserts that two `address` values are equal and includes error message into revert string on failure.
    function assertEq(address left, address right, string calldata err) external pure;

    /// Asserts that two `bytes32` values are equal.
    function assertEq(bytes32 left, bytes32 right) external pure;

    /// Asserts that two `bytes32` values are equal and includes error message into revert string on failure.
    function assertEq(bytes32 left, bytes32 right, string calldata err) external pure;

    /// Asserts that the given condition is false.
    function assertFalse(bool condition) external pure;

    /// Asserts that the given condition is false and includes error message into revert string on failure.
    function assertFalse(bool condition, string calldata err) external pure;

    /// Compares two `uint256` values. Expects first value to be greater than or equal to second.
    /// Formats values with decimals in failure message.
    function assertGeDecimal(uint256 left, uint256 right, uint256 decimals) external pure;

    /// Compares two `uint256` values. Expects first value to be greater than or equal to second.
    /// Formats values with decimals in failure message. Includes error message into revert string on failure.
    function assertGeDecimal(uint256 left, uint256 right, uint256 decimals, string calldata err) external pure;

    /// Compares two `int256` values. Expects first value to be greater than or equal to second.
    /// Formats values with decimals in failure message.
    function assertGeDecimal(int256 left, int256 right, uint256 decimals) external pure;

    /// Compares two `int256` values. Expects first value to be greater than or equal to second.
    /// Formats values with decimals in failure message. Includes error message into revert string on failure.
    function assertGeDecimal(int256 left, int256 right, uint256 decimals, string calldata err) external pure;

    /// Compares two `uint256` values. Expects first value to be greater than or equal to second.
    function assertGe(uint256 left, uint256 right) external pure;

    /// Compares two `uint256` values. Expects first value to be greater than or equal to second.
    /// Includes error message into revert string on failure.
    function assertGe(uint256 left, uint256 right, string calldata err) external pure;

    /// Compares two `int256` values. Expects first value to be greater than or equal to second.
    function assertGe(int256 left, int256 right) external pure;

    /// Compares two `int256` values. Expects first value to be greater than or equal to second.
    /// Includes error message into revert string on failure.
    function assertGe(int256 left, int256 right, string calldata err) external pure;

    /// Compares two `uint256` values. Expects first value to be greater than second.
    /// Formats values with decimals in failure message.
    function assertGtDecimal(uint256 left, uint256 right, uint256 decimals) external pure;

    /// Compares two `uint256` values. Expects first value to be greater than second.
    /// Formats values with decimals in failure message. Includes error message into revert string on failure.
    function assertGtDecimal(uint256 left, uint256 right, uint256 decimals, string calldata err) external pure;

    /// Compares two `int256` values. Expects first value to be greater than second.
    /// Formats values with decimals in failure message.
    function assertGtDecimal(int256 left, int256 right, uint256 decimals) external pure;

    /// Compares two `int256` values. Expects first value to be greater than second.
    /// Formats values with decimals in failure message. Includes error message into revert string on failure.
    function assertGtDecimal(int256 left, int256 right, uint256 decimals, string calldata err) external pure;

    /// Compares two `uint256` values. Expects first value to be greater than second.
    function assertGt(uint256 left, uint256 right) external pure;

    /// Compares two `uint256` values. Expects first value to be greater than second.
    /// Includes error message into revert string on failure.
    function assertGt(uint256 left, uint256 right, string calldata err) external pure;

    /// Compares two `int256` values. Expects first value to be greater than second.
    function assertGt(int256 left, int256 right) external pure;

    /// Compares two `int256` values. Expects first value to be greater than second.
    /// Includes error message into revert string on failure.
    function assertGt(int256 left, int256 right, string calldata err) external pure;

    /// Compares two `uint256` values. Expects first value to be less than or equal to second.
    /// Formats values with decimals in failure message.
    function assertLeDecimal(uint256 left, uint256 right, uint256 decimals) external pure;

    /// Compares two `uint256` values. Expects first value to be less than or equal to second.
    /// Formats values with decimals in failure message. Includes error message into revert string on failure.
    function assertLeDecimal(uint256 left, uint256 right, uint256 decimals, string calldata err) external pure;

    /// Compares two `int256` values. Expects first value to be less than or equal to second.
    /// Formats values with decimals in failure message.
    function assertLeDecimal(int256 left, int256 right, uint256 decimals) external pure;

    /// Compares two `int256` values. Expects first value to be less than or equal to second.
    /// Formats values with decimals in failure message. Includes error message into revert string on failure.
    function assertLeDecimal(int256 left, int256 right, uint256 decimals, string calldata err) external pure;

    /// Compares two `uint256` values. Expects first value to be less than or equal to second.
    function assertLe(uint256 left, uint256 right) external pure;

    /// Compares two `uint256` values. Expects first value to be less than or equal to second.
    /// Includes error message into revert string on failure.
    function assertLe(uint256 left, uint256 right, string calldata err) external pure;

    /// Compares two `int256` values. Expects first value to be less than or equal to second.
    function assertLe(int256 left, int256 right) external pure;

    /// Compares two `int256` values. Expects first value to be less than or equal to second.
    /// Includes error message into revert string on failure.
    function assertLe(int256 left, int256 right, string calldata err) external pure;

    /// Compares two `uint256` values. Expects first value to be less than second.
    /// Formats values with decimals in failure message.
    function assertLtDecimal(uint256 left, uint256 right, uint256 decimals) external pure;

    /// Compares two `uint256` values. Expects first value to be less than second.
    /// Formats values with decimals in failure message. Includes error message into revert string on failure.
    function assertLtDecimal(uint256 left, uint256 right, uint256 decimals, string calldata err) external pure;

    /// Compares two `int256` values. Expects first value to be less than second.
    /// Formats values with decimals in failure message.
    function assertLtDecimal(int256 left, int256 right, uint256 decimals) external pure;

    /// Compares two `int256` values. Expects first value to be less than second.
    /// Formats values with decimals in failure message. Includes error message into revert string on failure.
    function assertLtDecimal(int256 left, int256 right, uint256 decimals, string calldata err) external pure;

    /// Compares two `uint256` values. Expects first value to be less than second.
    function assertLt(uint256 left, uint256 right) external pure;

    /// Compares two `uint256` values. Expects first value to be less than second.
    /// Includes error message into revert string on failure.
    function assertLt(uint256 left, uint256 right, string calldata err) external pure;

    /// Compares two `int256` values. Expects first value to be less than second.
    function assertLt(int256 left, int256 right) external pure;

    /// Compares two `int256` values. Expects first value to be less than second.
    /// Includes error message into revert string on failure.
    function assertLt(int256 left, int256 right, string calldata err) external pure;

    /// Asserts that two `uint256` values are not equal, formatting them with decimals in failure message.
    function assertNotEqDecimal(uint256 left, uint256 right, uint256 decimals) external pure;

    /// Asserts that two `uint256` values are not equal, formatting them with decimals in failure message.
    /// Includes error message into revert string on failure.
    function assertNotEqDecimal(uint256 left, uint256 right, uint256 decimals, string calldata err) external pure;

    /// Asserts that two `int256` values are not equal, formatting them with decimals in failure message.
    function assertNotEqDecimal(int256 left, int256 right, uint256 decimals) external pure;

    /// Asserts that two `int256` values are not equal, formatting them with decimals in failure message.
    /// Includes error message into revert string on failure.
    function assertNotEqDecimal(int256 left, int256 right, uint256 decimals, string calldata err) external pure;

    /// Asserts that two `bool` values are not equal.
    function assertNotEq(bool left, bool right) external pure;

    /// Asserts that two `bool` values are not equal and includes error message into revert string on failure.
    function assertNotEq(bool left, bool right, string calldata err) external pure;

    /// Asserts that two `string` values are not equal.
    function assertNotEq(string calldata left, string calldata right) external pure;

    /// Asserts that two `string` values are not equal and includes error message into revert string on failure.
    function assertNotEq(string calldata left, string calldata right, string calldata err) external pure;

    /// Asserts that two `bytes` values are not equal.
    function assertNotEq(bytes calldata left, bytes calldata right) external pure;

    /// Asserts that two `bytes` values are not equal and includes error message into revert string on failure.
    function assertNotEq(bytes calldata left, bytes calldata right, string calldata err) external pure;

    /// Asserts that two arrays of `bool` values are not equal.
    function assertNotEq(bool[] calldata left, bool[] calldata right) external pure;

    /// Asserts that two arrays of `bool` values are not equal and includes error message into revert string on failure.
    function assertNotEq(bool[] calldata left, bool[] calldata right, string calldata err) external pure;

    /// Asserts that two arrays of `uint256` values are not equal.
    function assertNotEq(uint256[] calldata left, uint256[] calldata right) external pure;

    /// Asserts that two arrays of `uint256` values are not equal and includes error message into revert string on failure.
    function assertNotEq(uint256[] calldata left, uint256[] calldata right, string calldata err) external pure;

    /// Asserts that two arrays of `int256` values are not equal.
    function assertNotEq(int256[] calldata left, int256[] calldata right) external pure;

    /// Asserts that two arrays of `int256` values are not equal and includes error message into revert string on failure.
    function assertNotEq(int256[] calldata left, int256[] calldata right, string calldata err) external pure;

    /// Asserts that two `uint256` values are not equal.
    function assertNotEq(uint256 left, uint256 right) external pure;

    /// Asserts that two arrays of `address` values are not equal.
    function assertNotEq(address[] calldata left, address[] calldata right) external pure;

    /// Asserts that two arrays of `address` values are not equal and includes error message into revert string on failure.
    function assertNotEq(address[] calldata left, address[] calldata right, string calldata err) external pure;

    /// Asserts that two arrays of `bytes32` values are not equal.
    function assertNotEq(bytes32[] calldata left, bytes32[] calldata right) external pure;

    /// Asserts that two arrays of `bytes32` values are not equal and includes error message into revert string on failure.
    function assertNotEq(bytes32[] calldata left, bytes32[] calldata right, string calldata err) external pure;

    /// Asserts that two arrays of `string` values are not equal.
    function assertNotEq(string[] calldata left, string[] calldata right) external pure;

    /// Asserts that two arrays of `string` values are not equal and includes error message into revert string on failure.
    function assertNotEq(string[] calldata left, string[] calldata right, string calldata err) external pure;

    /// Asserts that two arrays of `bytes` values are not equal.
    function assertNotEq(bytes[] calldata left, bytes[] calldata right) external pure;

    /// Asserts that two arrays of `bytes` values are not equal and includes error message into revert string on failure.
    function assertNotEq(bytes[] calldata left, bytes[] calldata right, string calldata err) external pure;

    /// Asserts that two `uint256` values are not equal and includes error message into revert string on failure.
    function assertNotEq(uint256 left, uint256 right, string calldata err) external pure;

    /// Asserts that two `int256` values are not equal.
    function assertNotEq(int256 left, int256 right) external pure;

    /// Asserts that two `int256` values are not equal and includes error message into revert string on failure.
    function assertNotEq(int256 left, int256 right, string calldata err) external pure;

    /// Asserts that two `address` values are not equal.
    function assertNotEq(address left, address right) external pure;

    /// Asserts that two `address` values are not equal and includes error message into revert string on failure.
    function assertNotEq(address left, address right, string calldata err) external pure;

    /// Asserts that two `bytes32` values are not equal.
    function assertNotEq(bytes32 left, bytes32 right) external pure;

    /// Asserts that two `bytes32` values are not equal and includes error message into revert string on failure.
    function assertNotEq(bytes32 left, bytes32 right, string calldata err) external pure;

    /// Asserts that the given condition is true.
    function assertTrue(bool condition) external pure;

    /// Asserts that the given condition is true and includes error message into revert string on failure.
    function assertTrue(bool condition, string calldata err) external pure;

    /// If the condition is false, discard this run's fuzz inputs and generate new ones.
    function assume(bool condition) external pure;

    /// Skips a fuzz/invariant input unless `spender` is implicitly approved.
    function assumeImplicitApproval(address spender) external view;

    /// Discard this run's fuzz inputs and generate new ones if next call reverted.
    function assumeNoRevert() external pure;

    /// Discard this run's fuzz inputs and generate new ones if next call reverts with the potential revert parameters.
    function assumeNoRevert(PotentialRevert calldata potentialRevert) external pure;

    /// Discard this run's fuzz inputs and generate new ones if next call reverts with the any of the potential revert parameters.
    function assumeNoRevert(PotentialRevert[] calldata potentialReverts) external pure;

    /// Writes a breakpoint to jump to in the debugger.
    function breakpoint(string calldata char) external pure;

    /// Writes a conditional breakpoint to jump to in the debugger.
    function breakpoint(string calldata char, bool value) external pure;

    /// Returns true if the current Foundry version is greater than or equal to the given version.
    /// The given version string must be in the format `major.minor.patch`.
    /// This is equivalent to `foundryVersionCmp(version) >= 0`.
    function foundryVersionAtLeast(string calldata version) external view returns (bool);

    /// Compares the current Foundry version with the given version string.
    /// The given version string must be in the format `major.minor.patch`.
    /// Returns:
    /// -1 if current Foundry version is less than the given version
    /// 0 if current Foundry version equals the given version
    /// 1 if current Foundry version is greater than the given version
    /// This result can then be used with a comparison operator against `0`.
    /// For example, to check if the current Foundry version is greater than or equal to `1.0.0`:
    /// `if (foundryVersionCmp("1.0.0") >= 0) { ... }`
    function foundryVersionCmp(string calldata version) external view returns (int256);

    /// Returns a Chain struct for specific alias
    function getChain(string calldata chainAlias) external view returns (Chain memory chain);

    /// Returns a Chain struct for specific chainId
    function getChain(uint256 chainId) external view returns (Chain memory chain);

    /// Returns the Foundry version.
    /// Format: <cargo_version>-<tag>+<git_sha_short>.<unix_build_timestamp>.<profile>
    /// Sample output: 0.3.0-nightly+3cb96bde9b.1737036656.debug
    /// Note: Build timestamps may vary slightly across platforms due to separate CI jobs.
    /// For reliable version comparisons, use UNIX format (e.g., >= 1700000000)
    /// to compare timestamps while ignoring minor time differences.
    function getFoundryVersion() external view returns (string memory version);

    /// Returns the RPC url for the given alias.
    function rpcUrl(string calldata rpcAlias) external view returns (string memory json);

    /// Returns all rpc urls and their aliases as structs.
    function rpcUrlStructs() external view returns (Rpc[] memory urls);

    /// Returns all rpc urls and their aliases `[alias, url][]`.
    function rpcUrls() external view returns (string[2][] memory urls);

    /// Suspends execution of the main thread for `duration` milliseconds.
    function sleep(uint256 duration) external;

    // ======== Toml ========

    /// Checks if `key` exists in a TOML table.
    function keyExistsToml(string calldata toml, string calldata key) external view returns (bool);

    /// Parses a string of TOML data at `key` and coerces it to `address`.
    function parseTomlAddress(string calldata toml, string calldata key) external pure returns (address);

    /// Parses a string of TOML data at `key` and coerces it to `address[]`.
    function parseTomlAddressArray(string calldata toml, string calldata key) external pure returns (address[] memory);

    /// Parses a string of TOML data at `key` and coerces it to `bool`.
    function parseTomlBool(string calldata toml, string calldata key) external pure returns (bool);

    /// Parses a string of TOML data at `key` and coerces it to `bool[]`.
    function parseTomlBoolArray(string calldata toml, string calldata key) external pure returns (bool[] memory);

    /// Parses a string of TOML data at `key` and coerces it to `bytes`.
    function parseTomlBytes(string calldata toml, string calldata key) external pure returns (bytes memory);

    /// Parses a string of TOML data at `key` and coerces it to `bytes32`.
    function parseTomlBytes32(string calldata toml, string calldata key) external pure returns (bytes32);

    /// Parses a string of TOML data at `key` and coerces it to `bytes32[]`.
    function parseTomlBytes32Array(string calldata toml, string calldata key) external pure returns (bytes32[] memory);

    /// Parses a string of TOML data at `key` and coerces it to `bytes[]`.
    function parseTomlBytesArray(string calldata toml, string calldata key) external pure returns (bytes[] memory);

    /// Parses a string of TOML data at `key` and coerces it to `int256`.
    function parseTomlInt(string calldata toml, string calldata key) external pure returns (int256);

    /// Parses a string of TOML data at `key` and coerces it to `int256[]`.
    function parseTomlIntArray(string calldata toml, string calldata key) external pure returns (int256[] memory);

    /// Returns an array of all the keys in a TOML table.
    function parseTomlKeys(string calldata toml, string calldata key) external pure returns (string[] memory keys);

    /// Parses a string of TOML data at `key` and coerces it to `string`.
    function parseTomlString(string calldata toml, string calldata key) external pure returns (string memory);

    /// Parses a string of TOML data at `key` and coerces it to `string[]`.
    function parseTomlStringArray(string calldata toml, string calldata key) external pure returns (string[] memory);

    /// Parses a string of TOML data at `key` and coerces it to type array corresponding to `typeDescription`.
    function parseTomlTypeArray(string calldata toml, string calldata key, string calldata typeDescription)
        external
        pure
        returns (bytes memory);

    /// Parses a string of TOML data and coerces it to type corresponding to `typeDescription`.
    function parseTomlType(string calldata toml, string calldata typeDescription) external pure returns (bytes memory);

    /// Parses a string of TOML data at `key` and coerces it to type corresponding to `typeDescription`.
    function parseTomlType(string calldata toml, string calldata key, string calldata typeDescription)
        external
        pure
        returns (bytes memory);

    /// Parses a string of TOML data at `key` and coerces it to `uint256`.
    function parseTomlUint(string calldata toml, string calldata key) external pure returns (uint256);

    /// Parses a string of TOML data at `key` and coerces it to `uint256[]`.
    function parseTomlUintArray(string calldata toml, string calldata key) external pure returns (uint256[] memory);

    /// ABI-encodes a TOML table.
    function parseToml(string calldata toml) external pure returns (bytes memory abiEncodedData);

    /// ABI-encodes a TOML table at `key`.
    function parseToml(string calldata toml, string calldata key) external pure returns (bytes memory abiEncodedData);

    /// Takes serialized JSON, converts to TOML and write a serialized TOML to a file.
    function writeToml(string calldata json, string calldata path) external;

    /// Takes serialized JSON, converts to TOML and write a serialized TOML table to an **existing** TOML file, replacing a value with key = <value_key.>
    /// This is useful to replace a specific value of a TOML file, without having to parse the entire thing.
    /// This cheatcode will create new keys if they didn't previously exist.
    function writeToml(string calldata json, string calldata path, string calldata valueKey) external;

    // ======== Utilities ========

    /// Returns an uint256 value bounded in given range and different from the current one.
    function bound(uint256 current, uint256 min, uint256 max) external view returns (uint256);

    /// Returns an int256 value bounded in given range and different from the current one.
    function bound(int256 current, int256 min, int256 max) external view returns (int256);

    /// Compute the address of a contract created with CREATE2 using the given CREATE2 deployer.
    function computeCreate2Address(bytes32 salt, bytes32 initCodeHash, address deployer) external pure returns (address);

    /// Compute the address of a contract created with CREATE2 using the default CREATE2 deployer.
    function computeCreate2Address(bytes32 salt, bytes32 initCodeHash) external pure returns (address);

    /// Compute the address a contract will be deployed at for a given deployer address and nonce.
    function computeCreateAddress(address deployer, uint256 nonce) external pure returns (address);

    /// Generates the struct hash of the canonical EIP-712 type representation and its abi-encoded data.
    /// Supports 2 different inputs:
    /// 1. Name of the type (i.e. "PermitSingle"):
    /// * requires previous binding generation with `forge bind-json`.
    /// * bindings will be retrieved from the path configured in `foundry.toml`.
    /// 2. String representation of the type (i.e. "Foo(Bar bar) Bar(uint256 baz)").
    /// * Note: the cheatcode will use the canonical type even if the input is malformed
    /// with the wrong order of elements or with extra whitespaces.
    function eip712HashStruct(string calldata typeNameOrDefinition, bytes calldata abiEncodedData)
        external
        pure
        returns (bytes32 typeHash);

    /// Generates the struct hash of the canonical EIP-712 type representation and its abi-encoded data.
    /// Requires previous binding generation with `forge bind-json`.
    /// Params:
    /// * `bindingsPath`: path where the output of `forge bind-json` is stored.
    /// * `typeName`: Name of the type (i.e. "PermitSingle").
    /// * `abiEncodedData`: ABI-encoded data for the struct that is being hashed.
    function eip712HashStruct(string calldata bindingsPath, string calldata typeName, bytes calldata abiEncodedData)
        external
        pure
        returns (bytes32 typeHash);

    /// Generates the hash of the canonical EIP-712 type representation.
    /// Supports 2 different inputs:
    /// 1. Name of the type (i.e. "Transaction"):
    /// * requires previous binding generation with `forge bind-json`.
    /// * bindings will be retrieved from the path configured in `foundry.toml`.
    /// 2. String representation of the type (i.e. "Foo(Bar bar) Bar(uint256 baz)").
    /// * Note: the cheatcode will output the canonical type even if the input is malformed
    /// with the wrong order of elements or with extra whitespaces.
    function eip712HashType(string calldata typeNameOrDefinition) external pure returns (bytes32 typeHash);

    /// Generates the hash of the canonical EIP-712 type representation.
    /// Requires previous binding generation with `forge bind-json`.
    /// Params:
    /// * `bindingsPath`: path where the output of `forge bind-json` is stored.
    /// * `typeName`: Name of the type (i.e. "Transaction").
    function eip712HashType(string calldata bindingsPath, string calldata typeName)
        external
        pure
        returns (bytes32 typeHash);

    /// Generates a ready-to-sign digest of human-readable typed data following the EIP-712 standard.
    function eip712HashTypedData(string calldata jsonData) external pure returns (bytes32 digest);

    /// Returns ENS namehash for provided string.
    function ensNamehash(string calldata name) external pure returns (bytes32);

    /// RLP decodes an RLP payload into a list of bytes.
    function fromRlp(bytes calldata rlp) external pure returns (bytes[] memory data);

    /// Gets the label for the specified address.
    function getLabel(address account) external view returns (string memory currentLabel);

    /// Labels an address in call traces.
    function label(address account, string calldata newLabel) external;

    /// Pauses collection of call traces. Useful in cases when you want to skip tracing of
    /// complex calls which are not useful for debugging.
    function pauseTracing() external view;

    /// Returns a random `address`.
    function randomAddress() external view returns (address);

    /// Returns a random `bool`.
    function randomBool() external view returns (bool);

    /// Returns a random byte array value of the given length.
    function randomBytes(uint256 len) external view returns (bytes memory);

    /// Returns a random fixed-size byte array of length 4.
    function randomBytes4() external view returns (bytes4);

    /// Returns a random fixed-size byte array of length 8.
    function randomBytes8() external view returns (bytes8);

    /// Returns a random `int256` value.
    function randomInt() external view returns (int256);

    /// Returns a random `int256` value of given bits.
    function randomInt(uint256 bits) external view returns (int256);

    /// Returns a random uint256 value.
    function randomUint() external view returns (uint256);

    /// Returns random uint256 value between the provided range (=min..=max).
    function randomUint(uint256 min, uint256 max) external view returns (uint256);

    /// Returns a random `uint256` value of given bits.
    function randomUint(uint256 bits) external view returns (uint256);

    /// Unpauses collection of call traces.
    function resumeTracing() external view;

    /// Set RNG seed.
    function setSeed(uint256 seed) external;

    /// Randomly shuffles an array.
    function shuffle(uint256[] calldata array) external returns (uint256[] memory);

    /// Sorts an array in ascending order.
    function sort(uint256[] calldata array) external returns (uint256[] memory);

    /// Encodes a `bytes` value to a base64url string.
    function toBase64URL(bytes calldata data) external pure returns (string memory);

    /// Encodes a `string` value to a base64url string.
    function toBase64URL(string calldata data) external pure returns (string memory);

    /// Encodes a `bytes` value to a base64 string.
    function toBase64(bytes calldata data) external pure returns (string memory);

    /// Encodes a `string` value to a base64 string.
    function toBase64(string calldata data) external pure returns (string memory);

    /// RLP encodes a list of bytes into an RLP payload.
    function toRlp(bytes[] calldata data) external pure returns (bytes memory);
}

/// The `Vm` interface does allow manipulation of the EVM state. These are all intended to be used
/// in tests, but it is not recommended to use these cheats in scripts.
interface Vm is VmSafe {
    // ======== EVM ========

    /// Utility cheatcode to set an EIP-2930 access list for all subsequent transactions.
    function accessList(AccessListItem[] calldata access) external;

    /// Returns the identifier of the currently active fork. Reverts if no fork is currently active.
    function activeFork() external view returns (uint256 forkId);

    /// In forking mode, explicitly grant the given address cheatcode access.
    function allowCheatcodes(address account) external;

    /// Sets `block.blobbasefee`
    function blobBaseFee(uint256 newBlobBaseFee) external;

    /// Sets the blobhashes in the transaction.
    /// Not available on EVM versions before Cancun.
    /// If used on unsupported EVM versions it will revert.
    function blobhashes(bytes32[] calldata hashes) external;

    /// Sets `block.chainid`.
    function chainId(uint256 newChainId) external;

    /// Clears all mocked calls.
    function clearMockedCalls() external;

    /// Clones a source account code, state, balance and nonce to a target account and updates in-memory EVM state.
    function cloneAccount(address source, address target) external;

    /// Sets `block.coinbase`.
    function coinbase(address newCoinbase) external;

    /// Marks the slots of an account and the account address as cold.
    function cool(address target) external;

    /// Utility cheatcode to mark specific storage slot as cold, simulating no prior read.
    function coolSlot(address target, bytes32 slot) external;

    /// Creates a new fork with the given endpoint and the _latest_ block and returns the identifier of the fork.
    function createFork(string calldata urlOrAlias) external returns (uint256 forkId);

    /// Creates a new fork with the given endpoint and block and returns the identifier of the fork.
    function createFork(string calldata urlOrAlias, uint256 blockNumber) external returns (uint256 forkId);

    /// Creates a new fork with the given endpoint and at the block the given transaction was mined in,
    /// replays all transaction mined in the block before the transaction, and returns the identifier of the fork.
    function createFork(string calldata urlOrAlias, bytes32 txHash) external returns (uint256 forkId);

    /// Creates and also selects a new fork with the given endpoint and the latest block and returns the identifier of the fork.
    function createSelectFork(string calldata urlOrAlias) external returns (uint256 forkId);

    /// Creates and also selects a new fork with the given endpoint and block and returns the identifier of the fork.
    function createSelectFork(string calldata urlOrAlias, uint256 blockNumber) external returns (uint256 forkId);

    /// Creates and also selects new fork with the given endpoint and at the block the given transaction was mined in,
    /// replays all transaction mined in the block before the transaction, returns the identifier of the fork.
    function createSelectFork(string calldata urlOrAlias, bytes32 txHash) external returns (uint256 forkId);

    /// Sets an address' balance.
    function deal(address account, uint256 newBalance) external;

    /// Removes the snapshot with the given ID created by `snapshot`.
    /// Takes the snapshot ID to delete.
    /// Returns `true` if the snapshot was successfully deleted.
    /// Returns `false` if the snapshot does not exist.
    function deleteStateSnapshot(uint256 snapshotId) external returns (bool success);

    /// Removes _all_ snapshots previously created by `snapshot`.
    function deleteStateSnapshots() external;

    /// Sets `block.difficulty`.
    /// Not available on EVM versions from Paris onwards. Use `prevrandao` instead.
    /// Reverts if used on unsupported EVM versions.
    function difficulty(uint256 newDifficulty) external;

    /// Dump a genesis JSON file's `allocs` to disk.
    function dumpState(string calldata pathToStateJson) external;

    /// Sets an address' code.
    function etch(address target, bytes calldata newRuntimeBytecode) external;

    /// Executes an RLP-encoded signed transaction with full EVM semantics (like `--isolate` mode).
    /// The transaction is decoded from EIP-2718 format (type byte prefix + RLP payload) or legacy RLP.
    /// Returns the execution output bytes.
    /// This cheatcode is not allowed in `forge script` contexts.
    function executeTransaction(bytes calldata rawTx) external returns (bytes memory);

    /// Sets `block.basefee`.
    function fee(uint256 newBasefee) external;

    /// Gets the blockhashes from the current transaction.
    /// Not available on EVM versions before Cancun.
    /// If used on unsupported EVM versions it will revert.
    function getBlobhashes() external view returns (bytes32[] memory hashes);

    /// Returns true if the account is marked as persistent.
    function isPersistent(address account) external view returns (bool persistent);

    /// Load a genesis JSON file's `allocs` into the in-memory EVM state.
    function loadAllocs(string calldata pathToAllocsJson) external;

    /// Marks that the account(s) should use persistent storage across fork swaps in a multifork setup
    /// Meaning, changes made to the state of this account will be kept when switching forks.
    function makePersistent(address account) external;

    /// See `makePersistent(address)`.
    function makePersistent(address account0, address account1) external;

    /// See `makePersistent(address)`.
    function makePersistent(address account0, address account1, address account2) external;

    /// See `makePersistent(address)`.
    function makePersistent(address[] calldata accounts) external;

    /// Reverts a call to an address with specified revert data.
    function mockCallRevert(address callee, bytes calldata data, bytes calldata revertData) external;

    /// Reverts a call to an address with a specific `msg.value`, with specified revert data.
    function mockCallRevert(address callee, uint256 msgValue, bytes calldata data, bytes calldata revertData) external;

    /// Reverts a call to an address with specified revert data.
    /// Overload to pass the function selector directly `token.approve.selector` instead of `abi.encodeWithSelector(token.approve.selector)`.
    function mockCallRevert(address callee, bytes4 data, bytes calldata revertData) external;

    /// Reverts a call to an address with a specific `msg.value`, with specified revert data.
    /// Overload to pass the function selector directly `token.approve.selector` instead of `abi.encodeWithSelector(token.approve.selector)`.
    function mockCallRevert(address callee, uint256 msgValue, bytes4 data, bytes calldata revertData) external;

    /// Mocks a call to an address, returning specified data.
    /// Calldata can either be strict or a partial match, e.g. if you only
    /// pass a Solidity selector to the expected calldata, then the entire Solidity
    /// function will be mocked.
    function mockCall(address callee, bytes calldata data, bytes calldata returnData) external;

    /// Mocks a call to an address with a specific `msg.value`, returning specified data.
    /// Calldata match takes precedence over `msg.value` in case of ambiguity.
    function mockCall(address callee, uint256 msgValue, bytes calldata data, bytes calldata returnData) external;

    /// Mocks a call to an address, returning specified data.
    /// Calldata can either be strict or a partial match, e.g. if you only
    /// pass a Solidity selector to the expected calldata, then the entire Solidity
    /// function will be mocked.
    /// Overload to pass the function selector directly `token.approve.selector` instead of `abi.encodeWithSelector(token.approve.selector)`.
    function mockCall(address callee, bytes4 data, bytes calldata returnData) external;

    /// Mocks a call to an address with a specific `msg.value`, returning specified data.
    /// Calldata match takes precedence over `msg.value` in case of ambiguity.
    /// Overload to pass the function selector directly `token.approve.selector` instead of `abi.encodeWithSelector(token.approve.selector)`.
    function mockCall(address callee, uint256 msgValue, bytes4 data, bytes calldata returnData) external;

    /// Mocks a call to an address, returning specified data.
    /// Calldata can either be strict or a partial match, e.g. if you only
    /// pass a Solidity selector to the expected calldata, then the entire Solidity
    /// function will be mocked.
    /// Overload to control whether code is injected into `callee`. The other overloads etch a
    /// single byte into an empty account to circumvent Solidity's `extcodesize` check, with the
    /// side effect that unmocked calls to it no longer revert; `injectCode = false` leaves the
    /// account codeless, so unmocked calls to it revert in the caller. Mocked calls that return
    /// data still succeed, as Solidity checks `returndatasize()` instead of `extcodesize()` when
    /// return data is expected, but mocked calls to functions without return values may still
    /// revert in the caller due to the `extcodesize` check.
    function mockCall(address callee, bytes calldata data, bytes calldata returnData, bool injectCode) external;

    /// Mocks multiple calls to an address, returning specified data for each call.
    function mockCalls(address callee, bytes calldata data, bytes[] calldata returnData) external;

    /// Mocks multiple calls to an address with a specific `msg.value`, returning specified data for each call.
    function mockCalls(address callee, uint256 msgValue, bytes calldata data, bytes[] calldata returnData) external;

    /// Whenever a call is made to `callee` with calldata `data`, this cheatcode instead calls
    /// `target` with the same calldata. This functionality is similar to a delegate call made to
    /// `target` contract from `callee`.
    /// Can be used to substitute a call to a function with another implementation that captures
    /// the primary logic of the original function but is easier to reason about.
    /// If calldata is not a strict match then partial match by selector is attempted.
    function mockFunction(address callee, address target, bytes calldata data) external;

    /// Utility cheatcode to remove any EIP-2930 access list set by `accessList` cheatcode.
    function noAccessList() external;

    /// Sets the *next* call's `msg.sender` to be the input address.
    function prank(address msgSender) external;

    /// Sets the *next* call's `msg.sender` to be the input address, and the `tx.origin` to be the second input.
    function prank(address msgSender, address txOrigin) external;

    /// Sets the *next* delegate call's `msg.sender` to be the input address.
    function prank(address msgSender, bool delegateCall) external;

    /// Sets the *next* delegate call's `msg.sender` to be the input address, and the `tx.origin` to be the second input.
    function prank(address msgSender, address txOrigin, bool delegateCall) external;

    /// Sets `block.prevrandao`.
    /// Not available on EVM versions before Paris. Use `difficulty` instead.
    /// If used on unsupported EVM versions it will revert.
    function prevrandao(bytes32 newPrevrandao) external;

    /// Sets `block.prevrandao`.
    /// Not available on EVM versions before Paris. Use `difficulty` instead.
    /// If used on unsupported EVM versions it will revert.
    function prevrandao(uint256 newPrevrandao) external;

    /// Reads the current `msg.sender` and `tx.origin` from state and reports if there is any active caller modification.
    function readCallers() external view returns (CallerMode callerMode, address msgSender, address txOrigin);

    /// Resets the nonce of an account to 0 for EOAs and 1 for contract accounts.
    function resetNonce(address account) external;

    /// Revert the state of the EVM to a previous snapshot
    /// Takes the snapshot ID to revert to.
    /// Returns `true` if the snapshot was successfully reverted.
    /// Returns `false` if the snapshot does not exist.
    /// **Note:** This does not automatically delete the snapshot. To delete the snapshot use `deleteStateSnapshot`.
    function revertToState(uint256 snapshotId) external returns (bool success);

    /// Revert the state of the EVM to a previous snapshot and automatically deletes the snapshots
    /// Takes the snapshot ID to revert to.
    /// Returns `true` if the snapshot was successfully reverted and deleted.
    /// Returns `false` if the snapshot does not exist.
    function revertToStateAndDelete(uint256 snapshotId) external returns (bool success);

    /// Revokes persistent status from the address, previously added via `makePersistent`.
    function revokePersistent(address account) external;

    /// See `revokePersistent(address)`.
    function revokePersistent(address[] calldata accounts) external;

    /// Sets `block.height`.
    function roll(uint256 newHeight) external;

    /// Updates the currently active fork to given block number
    /// This is similar to `roll` but for the currently active fork.
    function rollFork(uint256 blockNumber) external;

    /// Updates the currently active fork to given transaction. This will `rollFork` with the number
    /// of the block the transaction was mined in and replays all transaction mined before it in the block.
    function rollFork(bytes32 txHash) external;

    /// Updates the given fork to given block number.
    function rollFork(uint256 forkId, uint256 blockNumber) external;

    /// Updates the given fork to block number of the given transaction and replays all transaction mined before it in the block.
    function rollFork(uint256 forkId, bytes32 txHash) external;

    /// Takes a fork identifier created by `createFork` and sets the corresponding forked state as active.
    function selectFork(uint256 forkId) external;

    /// Set blockhash for the current block.
    /// It only sets the blockhash for blocks where `block.number - 256 <= number < block.number`.
    function setBlockhash(uint256 blockNumber, bytes32 blockHash) external;

    /// Sets a TIP-20 token's logo URI directly in storage.
    /// This bypasses the token admin check, but still validates the URI against T5 constraints.
    function setLogoURI(address token, string calldata newLogoURI) external;

    /// Sets the nonce of an account. Must be higher than the current nonce of the account.
    function setNonce(address account, uint64 newNonce) external;

    /// Sets the nonce of an account to an arbitrary value.
    function setNonceUnsafe(address account, uint64 newNonce) external;

    /// Sets a TIP-20 token's logo URI directly in storage.
    /// This bypasses the token admin check, but still validates the URI against T5 constraints.
    function setTip20LogoURI(address token, string calldata newLogoURI) external;

    /// Snapshot capture the gas usage of the last call or create by name from the callee perspective.
    function snapshotGasLastFrame(string calldata name) external returns (uint256 gasUsed);

    /// Snapshot capture the gas usage of the last call or create by name in a group from the callee perspective.
    function snapshotGasLastFrame(string calldata group, string calldata name) external returns (uint256 gasUsed);

    /// Snapshot the current state of the evm.
    /// Returns the ID of the snapshot that was created.
    /// To revert a snapshot use `revertToState`.
    function snapshotState() external returns (uint256 snapshotId);

    /// Snapshot capture an arbitrary numerical value by name.
    /// The group name is derived from the contract name.
    function snapshotValue(string calldata name, uint256 value) external;

    /// Snapshot capture an arbitrary numerical value by name in a group.
    function snapshotValue(string calldata group, string calldata name, uint256 value) external;

    /// Sets all subsequent calls' `msg.sender` to be the input address until `stopPrank` is called.
    function startPrank(address msgSender) external;

    /// Sets all subsequent calls' `msg.sender` to be the input address until `stopPrank` is called, and the `tx.origin` to be the second input.
    function startPrank(address msgSender, address txOrigin) external;

    /// Sets all subsequent delegate calls' `msg.sender` to be the input address until `stopPrank` is called.
    function startPrank(address msgSender, bool delegateCall) external;

    /// Sets all subsequent delegate calls' `msg.sender` to be the input address until `stopPrank` is called, and the `tx.origin` to be the second input.
    function startPrank(address msgSender, address txOrigin, bool delegateCall) external;

    /// Start a snapshot capture of the current gas usage by name.
    /// The group name is derived from the contract name.
    function startSnapshotGas(string calldata name) external;

    /// Start a snapshot capture of the current gas usage by name in a group.
    function startSnapshotGas(string calldata group, string calldata name) external;

    /// Resets subsequent calls' `msg.sender` to be `address(this)`.
    function stopPrank() external;

    /// Stop the snapshot capture of the current gas by latest snapshot name, capturing the gas used since the start.
    function stopSnapshotGas() external returns (uint256 gasUsed);

    /// Stop the snapshot capture of the current gas usage by name, capturing the gas used since the start.
    /// The group name is derived from the contract name.
    function stopSnapshotGas(string calldata name) external returns (uint256 gasUsed);

    /// Stop the snapshot capture of the current gas usage by name in a group, capturing the gas used since the start.
    function stopSnapshotGas(string calldata group, string calldata name) external returns (uint256 gasUsed);

    /// Stores a value to an address' storage slot.
    function store(address target, bytes32 slot, bytes32 value) external;

    /// Fetches the given transaction from the active fork and executes it on the current state.
    function transact(bytes32 txHash) external;

    /// Fetches the given transaction from the given fork and executes it on the current state.
    function transact(uint256 forkId, bytes32 txHash) external;

    /// Sets `tx.gasprice`.
    function txGasPrice(uint256 newGasPrice) external;

    /// Utility cheatcode to mark specific storage slot as warm, simulating a prior read.
    function warmSlot(address target, bytes32 slot) external;

    /// Sets `block.timestamp`.
    function warp(uint256 newTimestamp) external;

    /// `deleteSnapshot` is being deprecated in favor of `deleteStateSnapshot`. It will be removed in future versions.
    function deleteSnapshot(uint256 snapshotId) external returns (bool success);

    /// `deleteSnapshots` is being deprecated in favor of `deleteStateSnapshots`. It will be removed in future versions.
    function deleteSnapshots() external;

    /// `revertToAndDelete` is being deprecated in favor of `revertToStateAndDelete`. It will be removed in future versions.
    function revertToAndDelete(uint256 snapshotId) external returns (bool success);

    /// `revertTo` is being deprecated in favor of `revertToState`. It will be removed in future versions.
    function revertTo(uint256 snapshotId) external returns (bool success);

    /// DEPRECATED: use `snapshotGasLastFrame` instead.
    /// Snapshot capture the gas usage of the last call by name from the callee perspective.
    function snapshotGasLastCall(string calldata name) external returns (uint256 gasUsed);

    /// DEPRECATED: use `snapshotGasLastFrame` instead.
    /// Snapshot capture the gas usage of the last call by name in a group from the callee perspective.
    function snapshotGasLastCall(string calldata group, string calldata name) external returns (uint256 gasUsed);

    /// `snapshot` is being deprecated in favor of `snapshotState`. It will be removed in future versions.
    function snapshot() external returns (uint256 snapshotId);

    // ======== Testing ========

    /// Expect a call to an address with the specified `msg.value` and calldata, and a *minimum* amount of gas.
    function expectCallMinGas(address callee, uint256 msgValue, uint64 minGas, bytes calldata data) external;

    /// Expect given number of calls to an address with the specified `msg.value` and calldata, and a *minimum* amount of gas.
    function expectCallMinGas(address callee, uint256 msgValue, uint64 minGas, bytes calldata data, uint64 count)
        external;

    /// Expects a call to an address with the specified calldata.
    /// Calldata can either be a strict or a partial match.
    function expectCall(address callee, bytes calldata data) external;

    /// Expects given number of calls to an address with the specified calldata.
    function expectCall(address callee, bytes calldata data, uint64 count) external;

    /// Expects a call to an address with the specified `msg.value` and calldata.
    function expectCall(address callee, uint256 msgValue, bytes calldata data) external;

    /// Expects given number of calls to an address with the specified `msg.value` and calldata.
    function expectCall(address callee, uint256 msgValue, bytes calldata data, uint64 count) external;

    /// Expect a call to an address with the specified `msg.value`, gas, and calldata.
    function expectCall(address callee, uint256 msgValue, uint64 gas, bytes calldata data) external;

    /// Expects given number of calls to an address with the specified `msg.value`, gas, and calldata.
    function expectCall(address callee, uint256 msgValue, uint64 gas, bytes calldata data, uint64 count) external;

    /// Expects the deployment of the specified bytecode by the specified address using the CREATE opcode
    function expectCreate(bytes calldata bytecode, address deployer) external;

    /// Expects the deployment of the specified bytecode by the specified address using the CREATE2 opcode
    function expectCreate2(bytes calldata bytecode, address deployer) external;

    /// Prepare an expected anonymous log with (bool checkTopic1, bool checkTopic2, bool checkTopic3, bool checkData.).
    /// Call this function, then emit an anonymous event, then call a function. Internally after the call, we check if
    /// logs were emitted in the expected order with the expected topics and data (as specified by the booleans).
    function expectEmitAnonymous(bool checkTopic0, bool checkTopic1, bool checkTopic2, bool checkTopic3, bool checkData)
        external;

    /// Same as the previous method, but also checks supplied address against emitting contract.
    function expectEmitAnonymous(
        bool checkTopic0,
        bool checkTopic1,
        bool checkTopic2,
        bool checkTopic3,
        bool checkData,
        address emitter
    ) external;

    /// Prepare an expected anonymous log with all topic and data checks enabled.
    /// Call this function, then emit an anonymous event, then call a function. Internally after the call, we check if
    /// logs were emitted in the expected order with the expected topics and data.
    function expectEmitAnonymous() external;

    /// Same as the previous method, but also checks supplied address against emitting contract.
    function expectEmitAnonymous(address emitter) external;

    /// Prepare an expected log with (bool checkTopic1, bool checkTopic2, bool checkTopic3, bool checkData.).
    /// Call this function, then emit an event, then call a function. Internally after the call, we check if
    /// logs were emitted in the expected order with the expected topics and data (as specified by the booleans).
    /// Must be placed immediately before the call you want to assert on. If the next call reverts and the
    /// revert is caught by the caller (low-level call or try/catch), the expectation remains active and may
    /// be satisfied by a log emitted from a later call.
    function expectEmit(bool checkTopic1, bool checkTopic2, bool checkTopic3, bool checkData) external;

    /// Same as the previous method, but also checks supplied address against emitting contract.
    function expectEmit(bool checkTopic1, bool checkTopic2, bool checkTopic3, bool checkData, address emitter) external;

    /// Prepare an expected log with all topic and data checks enabled.
    /// Call this function, then emit an event, then call a function. Internally after the call, we check if
    /// logs were emitted in the expected order with the expected topics and data.
    /// Must be placed immediately before the call you want to assert on. If the next call reverts and the
    /// revert is caught by the caller (low-level call or try/catch), the expectation remains active and may
    /// be satisfied by a log emitted from a later call.
    function expectEmit() external;

    /// Same as the previous method, but also checks supplied address against emitting contract.
    function expectEmit(address emitter) external;

    /// Expect a given number of logs with the provided topics.
    function expectEmit(bool checkTopic1, bool checkTopic2, bool checkTopic3, bool checkData, uint64 count) external;

    /// Expect a given number of logs from a specific emitter with the provided topics.
    function expectEmit(
        bool checkTopic1,
        bool checkTopic2,
        bool checkTopic3,
        bool checkData,
        address emitter,
        uint64 count
    ) external;

    /// Expect a given number of logs with all topic and data checks enabled.
    function expectEmit(uint64 count) external;

    /// Expect a given number of logs from a specific emitter with all topic and data checks enabled.
    function expectEmit(address emitter, uint64 count) external;

    /// Expects a call to `SignatureVerifier.verifyKeychainAdmin(account, digest, signature)`.
    /// The supplied `digest` should already be domain-separated with chain ID, contract address,
    /// and account address.
    function expectKeychainAdminVerified(address account, bytes32 digest, bytes calldata signature) external;

    /// Expects a call to `SignatureVerifier.verifyKeychain(account, digest, signature)`.
    function expectKeychainVerified(address account, bytes32 digest, bytes calldata signature) external;

    /// Expects a TIP-20 `LogoURIUpdated(address indexed updater, string newLogoURI)` event.
    function expectLogoURIUpdated(address token, address updater, string calldata newLogoURI) external;

    /// Expects an error on next call that starts with the revert data.
    function expectPartialRevert(bytes4 revertData) external;

    /// Expects an error on next call to reverter address, that starts with the revert data.
    /// See `expectRevert(address)` for `reverter` matching semantics.
    function expectPartialRevert(bytes4 revertData, address reverter) external;

    /// Expects an error on next call with any revert data.
    function expectRevert() external;

    /// Expects an error on next call that exactly matches the revert data.
    function expectRevert(bytes4 revertData) external;

    /// Expects a `count` number of reverts from the upcoming calls from the reverter address that match the revert data.
    /// See `expectRevert(address)` for `reverter` matching semantics.
    function expectRevert(bytes4 revertData, address reverter, uint64 count) external;

    /// Expects a `count` number of reverts from the upcoming calls from the reverter address that exactly match the revert data.
    /// See `expectRevert(address)` for `reverter` matching semantics.
    function expectRevert(bytes calldata revertData, address reverter, uint64 count) external;

    /// Expects an error on next call that exactly matches the revert data.
    function expectRevert(bytes calldata revertData) external;

    /// Expects an error with any revert data on next call to reverter address.
    /// The `reverter` argument is matched against the address associated with
    /// the frame that produced the revert:
    /// - For a CALL: the address that was called.
    /// - For a CREATE / CREATE2: the would-be deployed address of the failed
    /// deployment (computed from the deployer + nonce, or salt + initcode).
    /// For a single expected revert, the innermost reverting frame wins in
    /// nested CALL, CREATE, or mixed chains. With `count > 1`, nested
    /// CREATE / CREATE2 chains apply the same rule independently to each
    /// iteration; nested CALL chains keep their existing
    /// outermost-call-per-iteration behavior.
    function expectRevert(address reverter) external;

    /// Expects an error from reverter address on next call, with any revert data.
    /// See `expectRevert(address)` for `reverter` matching semantics.
    function expectRevert(bytes4 revertData, address reverter) external;

    /// Expects an error from reverter address on next call, that exactly matches the revert data.
    /// See `expectRevert(address)` for `reverter` matching semantics.
    function expectRevert(bytes calldata revertData, address reverter) external;

    /// Expects a `count` number of reverts from the upcoming calls with any revert data or reverter.
    function expectRevert(uint64 count) external;

    /// Expects a `count` number of reverts from the upcoming calls that match the revert data.
    function expectRevert(bytes4 revertData, uint64 count) external;

    /// Expects a `count` number of reverts from the upcoming calls that exactly match the revert data.
    function expectRevert(bytes calldata revertData, uint64 count) external;

    /// Expects a `count` number of reverts from the upcoming calls from the reverter address.
    /// See `expectRevert(address)` for `reverter` matching semantics.
    function expectRevert(address reverter, uint64 count) external;

    /// Only allows memory writes to offsets [0x00, 0x60) ∪ [min, max) in the current subcontext. If any other
    /// memory is written to, the test will fail. Can be called multiple times to add more ranges to the set.
    function expectSafeMemory(uint64 min, uint64 max) external;

    /// Only allows memory writes to offsets [0x00, 0x60) ∪ [min, max) in the next created subcontext.
    /// If any other memory is written to, the test will fail. Can be called multiple times to add more ranges
    /// to the set.
    function expectSafeMemoryCall(uint64 min, uint64 max) external;

    /// Expects a TIP-20 `LogoURIUpdated(address indexed updater, string newLogoURI)` event.
    function expectTip20LogoURIUpdated(address token, address updater, string calldata newLogoURI) external;

    /// Marks a test as skipped. Must be called at the top level of a test.
    function skip(bool skipTest) external;

    /// Marks a test as skipped with a reason. Must be called at the top level of a test.
    function skip(bool skipTest, string calldata reason) external;

    /// Stops all safe memory expectation in the current subcontext.
    function stopExpectSafeMemory() external;

    // ======== Utilities ========

    /// Utility cheatcode to copy storage of `from` contract to another `to` contract.
    function copyStorage(address from, address to) external;

    /// Causes the next contract creation (via new) to fail and return its initcode in the returndata buffer.
    /// This allows type-safe access to the initcode payload that would be used for contract creation.
    /// Example usage:
    /// vm.interceptInitcode();
    /// bytes memory initcode;
    /// try new MyContract(param1, param2) { assert(false); }
    /// catch (bytes memory interceptedInitcode) { initcode = interceptedInitcode; }
    function interceptInitcode() external;

    /// Utility cheatcode to set arbitrary storage for given target address.
    function setArbitraryStorage(address target) external;

    /// Utility cheatcode to set arbitrary storage for given target address and overwrite
    /// any storage slots that have been previously set.
    function setArbitraryStorage(address target, bool overwrite) external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/dss/VowAbstract.sol

// https://github.com/makerdao/dss/blob/master/src/vow.sol
interface VowAbstract {
    function wards(address) external view returns (uint256);
    function rely(address usr) external;
    function deny(address usr) external;
    function vat() external view returns (address);
    function flapper() external view returns (address);
    function flopper() external view returns (address);
    function sin(uint256) external view returns (uint256);
    function Sin() external view returns (uint256);
    function Ash() external view returns (uint256);
    function wait() external view returns (uint256);
    function dump() external view returns (uint256);
    function sump() external view returns (uint256);
    function bump() external view returns (uint256);
    function hump() external view returns (uint256);
    function live() external view returns (uint256);
    function file(bytes32, uint256) external;
    function file(bytes32, address) external;
    function fess(uint256) external;
    function flog(uint256) external;
    function heal(uint256) external;
    function kiss(uint256) external;
    function flop() external returns (uint256);
    function flap() external returns (uint256);
    function cage() external;
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/utils/WardsAbstract.sol

interface WardsAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
}

// node_modules/@openzeppelin/contracts/interfaces/draft-IERC1822.sol

// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/draft-IERC1822.sol)

/**
 * @dev ERC-1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822Proxiable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// node_modules/@openzeppelin/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v5.4.0) (utils/Address.sol)

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert Errors.InsufficientBalance(address(this).balance, amount);
        }

        (bool success, bytes memory returndata) = recipient.call{value: amount}("");
        if (!success) {
            _revert(returndata);
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {Errors.FailedCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert Errors.InsufficientBalance(address(this).balance, value);
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {Errors.FailedCall}) in case
     * of an unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {Errors.FailedCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {Errors.FailedCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            assembly ("memory-safe") {
                revert(add(returndata, 0x20), mload(returndata))
            }
        } else {
            revert Errors.FailedCall();
        }
    }
}

// lib/forge-std/src/StdJson.sol

// Helpers for parsing and writing JSON files.
// `key` parameters use the same selector syntax as the `vm.parseJson*` cheatcodes,
// for example `.a` for a nested field or `$` for the root object.
// To parse:
// ```
// using stdJson for string;
// string memory json = vm.readFile("<some_path>");
// uint256 value = json.readUint(".a");
// bytes memory encoded = json.parseRaw("$");
// ```
// To write:
// ```
// using stdJson for string;
// string memory json = "json";
// json.serialize("a", uint256(123));
// string memory semiFinal = json.serialize("b", string("test"));
// string memory finalJson = json.serialize("c", semiFinal);
// finalJson.write("<some_path>");
// ```

library stdJson {
    VmSafe private constant vm = VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))));

    /// @notice Returns whether `key` exists in `json`.
    /// @dev `key` uses the same selector syntax as `vm.parseJson*`, such as `.a` or `$`.
    function keyExists(string memory json, string memory key) internal view returns (bool) {
        return vm.keyExistsJson(json, key);
    }

    /// @notice ABI-encodes the JSON value selected by `key`.
    /// @dev `key` uses the same selector syntax as `vm.parseJson*`, such as `.a` or `$`.
    function parseRaw(string memory json, string memory key) internal pure returns (bytes memory) {
        return vm.parseJson(json, key);
    }

    /// @notice Reads a uint256 value at `key` from `json`.
    function readUint(string memory json, string memory key) internal pure returns (uint256) {
        return vm.parseJsonUint(json, key);
    }

    /// @notice Reads a uint256 array at `key` from `json`.
    function readUintArray(string memory json, string memory key) internal pure returns (uint256[] memory) {
        return vm.parseJsonUintArray(json, key);
    }

    /// @notice Reads an int256 value at `key` from `json`.
    function readInt(string memory json, string memory key) internal pure returns (int256) {
        return vm.parseJsonInt(json, key);
    }

    /// @notice Reads an int256 array at `key` from `json`.
    function readIntArray(string memory json, string memory key) internal pure returns (int256[] memory) {
        return vm.parseJsonIntArray(json, key);
    }

    /// @notice Reads a bytes32 value at `key` from `json`.
    function readBytes32(string memory json, string memory key) internal pure returns (bytes32) {
        return vm.parseJsonBytes32(json, key);
    }

    /// @notice Reads a bytes32 array at `key` from `json`.
    function readBytes32Array(string memory json, string memory key) internal pure returns (bytes32[] memory) {
        return vm.parseJsonBytes32Array(json, key);
    }

    /// @notice Reads a string value at `key` from `json`.
    function readString(string memory json, string memory key) internal pure returns (string memory) {
        return vm.parseJsonString(json, key);
    }

    /// @notice Reads a string array at `key` from `json`.
    function readStringArray(string memory json, string memory key) internal pure returns (string[] memory) {
        return vm.parseJsonStringArray(json, key);
    }

    /// @notice Reads an address value at `key` from `json`.
    function readAddress(string memory json, string memory key) internal pure returns (address) {
        return vm.parseJsonAddress(json, key);
    }

    /// @notice Reads an address array at `key` from `json`.
    function readAddressArray(string memory json, string memory key) internal pure returns (address[] memory) {
        return vm.parseJsonAddressArray(json, key);
    }

    /// @notice Reads a bool value at `key` from `json`.
    function readBool(string memory json, string memory key) internal pure returns (bool) {
        return vm.parseJsonBool(json, key);
    }

    /// @notice Reads a bool array at `key` from `json`.
    function readBoolArray(string memory json, string memory key) internal pure returns (bool[] memory) {
        return vm.parseJsonBoolArray(json, key);
    }

    /// @notice Reads a bytes value at `key` from `json`.
    function readBytes(string memory json, string memory key) internal pure returns (bytes memory) {
        return vm.parseJsonBytes(json, key);
    }

    /// @notice Reads a bytes array at `key` from `json`.
    function readBytesArray(string memory json, string memory key) internal pure returns (bytes[] memory) {
        return vm.parseJsonBytesArray(json, key);
    }

    /// @notice Reads a uint256 value at `key` from `json`, returning `defaultValue` if the key does not exist.
    function readUintOr(string memory json, string memory key, uint256 defaultValue) internal view returns (uint256) {
        return keyExists(json, key) ? readUint(json, key) : defaultValue;
    }

    /// @notice Reads a uint256 array at `key` from `json`, returning `defaultValue` if the key does not exist.
    function readUintArrayOr(string memory json, string memory key, uint256[] memory defaultValue)
        internal
        view
        returns (uint256[] memory)
    {
        return keyExists(json, key) ? readUintArray(json, key) : defaultValue;
    }

    /// @notice Reads an int256 value at `key` from `json`, returning `defaultValue` if the key does not exist.
    function readIntOr(string memory json, string memory key, int256 defaultValue) internal view returns (int256) {
        return keyExists(json, key) ? readInt(json, key) : defaultValue;
    }

    /// @notice Reads an int256 array at `key` from `json`, returning `defaultValue` if the key does not exist.
    function readIntArrayOr(string memory json, string memory key, int256[] memory defaultValue)
        internal
        view
        returns (int256[] memory)
    {
        return keyExists(json, key) ? readIntArray(json, key) : defaultValue;
    }

    /// @notice Reads a bytes32 value at `key` from `json`, returning `defaultValue` if the key does not exist.
    function readBytes32Or(string memory json, string memory key, bytes32 defaultValue)
        internal
        view
        returns (bytes32)
    {
        return keyExists(json, key) ? readBytes32(json, key) : defaultValue;
    }

    /// @notice Reads a bytes32 array at `key` from `json`, returning `defaultValue` if the key does not exist.
    function readBytes32ArrayOr(string memory json, string memory key, bytes32[] memory defaultValue)
        internal
        view
        returns (bytes32[] memory)
    {
        return keyExists(json, key) ? readBytes32Array(json, key) : defaultValue;
    }

    /// @notice Reads a string value at `key` from `json`, returning `defaultValue` if the key does not exist.
    function readStringOr(string memory json, string memory key, string memory defaultValue)
        internal
        view
        returns (string memory)
    {
        return keyExists(json, key) ? readString(json, key) : defaultValue;
    }

    /// @notice Reads a string array at `key` from `json`, returning `defaultValue` if the key does not exist.
    function readStringArrayOr(string memory json, string memory key, string[] memory defaultValue)
        internal
        view
        returns (string[] memory)
    {
        return keyExists(json, key) ? readStringArray(json, key) : defaultValue;
    }

    /// @notice Reads an address value at `key` from `json`, returning `defaultValue` if the key does not exist.
    function readAddressOr(string memory json, string memory key, address defaultValue)
        internal
        view
        returns (address)
    {
        return keyExists(json, key) ? readAddress(json, key) : defaultValue;
    }

    /// @notice Reads an address array at `key` from `json`, returning `defaultValue` if the key does not exist.
    function readAddressArrayOr(string memory json, string memory key, address[] memory defaultValue)
        internal
        view
        returns (address[] memory)
    {
        return keyExists(json, key) ? readAddressArray(json, key) : defaultValue;
    }

    /// @notice Reads a bool value at `key` from `json`, returning `defaultValue` if the key does not exist.
    function readBoolOr(string memory json, string memory key, bool defaultValue) internal view returns (bool) {
        return keyExists(json, key) ? readBool(json, key) : defaultValue;
    }

    /// @notice Reads a bool array at `key` from `json`, returning `defaultValue` if the key does not exist.
    function readBoolArrayOr(string memory json, string memory key, bool[] memory defaultValue)
        internal
        view
        returns (bool[] memory)
    {
        return keyExists(json, key) ? readBoolArray(json, key) : defaultValue;
    }

    /// @notice Reads a bytes value at `key` from `json`, returning `defaultValue` if the key does not exist.
    function readBytesOr(string memory json, string memory key, bytes memory defaultValue)
        internal
        view
        returns (bytes memory)
    {
        return keyExists(json, key) ? readBytes(json, key) : defaultValue;
    }

    /// @notice Reads a bytes array at `key` from `json`, returning `defaultValue` if the key does not exist.
    function readBytesArrayOr(string memory json, string memory key, bytes[] memory defaultValue)
        internal
        view
        returns (bytes[] memory)
    {
        return keyExists(json, key) ? readBytesArray(json, key) : defaultValue;
    }

    /// @notice Serializes a JSON object `rootObject` under `jsonKey` and returns the serialized JSON string.
    function serialize(string memory jsonKey, string memory rootObject) internal returns (string memory) {
        return vm.serializeJson(jsonKey, rootObject);
    }

    /// @notice Serializes a bool `value` under `key` within `jsonKey` and returns the serialized JSON string.
    function serialize(string memory jsonKey, string memory key, bool value) internal returns (string memory) {
        return vm.serializeBool(jsonKey, key, value);
    }

    /// @notice Serializes a bool array `value` under `key` within `jsonKey` and returns the serialized JSON string.
    function serialize(string memory jsonKey, string memory key, bool[] memory value) internal returns (string memory) {
        return vm.serializeBool(jsonKey, key, value);
    }

    /// @notice Serializes a uint256 `value` under `key` within `jsonKey` and returns the serialized JSON string.
    function serialize(string memory jsonKey, string memory key, uint256 value) internal returns (string memory) {
        return vm.serializeUint(jsonKey, key, value);
    }

    /// @notice Serializes a uint256 array `value` under `key` within `jsonKey` and returns the serialized JSON string.
    function serialize(string memory jsonKey, string memory key, uint256[] memory value)
        internal
        returns (string memory)
    {
        return vm.serializeUint(jsonKey, key, value);
    }

    /// @notice Serializes an int256 `value` under `key` within `jsonKey` and returns the serialized JSON string.
    function serialize(string memory jsonKey, string memory key, int256 value) internal returns (string memory) {
        return vm.serializeInt(jsonKey, key, value);
    }

    /// @notice Serializes an int256 array `value` under `key` within `jsonKey` and returns the serialized JSON string.
    function serialize(string memory jsonKey, string memory key, int256[] memory value)
        internal
        returns (string memory)
    {
        return vm.serializeInt(jsonKey, key, value);
    }

    /// @notice Serializes an address `value` under `key` within `jsonKey` and returns the serialized JSON string.
    function serialize(string memory jsonKey, string memory key, address value) internal returns (string memory) {
        return vm.serializeAddress(jsonKey, key, value);
    }

    /// @notice Serializes an address array `value` under `key` within `jsonKey` and returns the serialized JSON string.
    function serialize(string memory jsonKey, string memory key, address[] memory value)
        internal
        returns (string memory)
    {
        return vm.serializeAddress(jsonKey, key, value);
    }

    /// @notice Serializes a bytes32 `value` under `key` within `jsonKey` and returns the serialized JSON string.
    function serialize(string memory jsonKey, string memory key, bytes32 value) internal returns (string memory) {
        return vm.serializeBytes32(jsonKey, key, value);
    }

    /// @notice Serializes a bytes32 array `value` under `key` within `jsonKey` and returns the serialized JSON string.
    function serialize(string memory jsonKey, string memory key, bytes32[] memory value)
        internal
        returns (string memory)
    {
        return vm.serializeBytes32(jsonKey, key, value);
    }

    /// @notice Serializes a bytes `value` under `key` within `jsonKey` and returns the serialized JSON string.
    function serialize(string memory jsonKey, string memory key, bytes memory value) internal returns (string memory) {
        return vm.serializeBytes(jsonKey, key, value);
    }

    /// @notice Serializes a bytes array `value` under `key` within `jsonKey` and returns the serialized JSON string.
    function serialize(string memory jsonKey, string memory key, bytes[] memory value)
        internal
        returns (string memory)
    {
        return vm.serializeBytes(jsonKey, key, value);
    }

    /// @notice Serializes a string `value` under `key` within `jsonKey` and returns the serialized JSON string.
    function serialize(string memory jsonKey, string memory key, string memory value) internal returns (string memory) {
        return vm.serializeString(jsonKey, key, value);
    }

    /// @notice Serializes a string array `value` under `key` within `jsonKey` and returns the serialized JSON string.
    function serialize(string memory jsonKey, string memory key, string[] memory value)
        internal
        returns (string memory)
    {
        return vm.serializeString(jsonKey, key, value);
    }

    /// @notice Writes the serialized JSON object `jsonKey` to `path`.
    function write(string memory jsonKey, string memory path) internal {
        vm.writeJson(jsonKey, path);
    }

    /// @notice Writes the value at `valueKey` from the serialized JSON object `jsonKey` to `path`.
    function write(string memory jsonKey, string memory path, string memory valueKey) internal {
        vm.writeJson(jsonKey, path, valueKey);
    }
}

// node_modules/@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol

// OpenZeppelin Contracts (last updated v5.4.0) (proxy/ERC1967/ERC1967Utils.sol)

/**
 * @dev This library provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[ERC-1967] slots.
 */
library ERC1967Utils {
    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1.
     */
    // solhint-disable-next-line private-vars-leading-underscore
    bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev The `implementation` of the proxy is invalid.
     */
    error ERC1967InvalidImplementation(address implementation);

    /**
     * @dev The `admin` of the proxy is invalid.
     */
    error ERC1967InvalidAdmin(address admin);

    /**
     * @dev The `beacon` of the proxy is invalid.
     */
    error ERC1967InvalidBeacon(address beacon);

    /**
     * @dev An upgrade function sees `msg.value > 0` that may be lost.
     */
    error ERC1967NonPayable();

    /**
     * @dev Returns the current implementation address.
     */
    function getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the ERC-1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        if (newImplementation.code.length == 0) {
            revert ERC1967InvalidImplementation(newImplementation);
        }
        StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Performs implementation upgrade with additional setup call if data is nonempty.
     * This function is payable only if the setup call is performed, otherwise `msg.value` is rejected
     * to avoid stuck value in the contract.
     *
     * Emits an {IERC1967-Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) internal {
        _setImplementation(newImplementation);
        emit IERC1967.Upgraded(newImplementation);

        if (data.length > 0) {
            Address.functionDelegateCall(newImplementation, data);
        } else {
            _checkNonPayable();
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1.
     */
    // solhint-disable-next-line private-vars-leading-underscore
    bytes32 internal constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Returns the current admin.
     *
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by ERC-1967) using
     * the https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`
     */
    function getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the ERC-1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        if (newAdmin == address(0)) {
            revert ERC1967InvalidAdmin(address(0));
        }
        StorageSlot.getAddressSlot(ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {IERC1967-AdminChanged} event.
     */
    function changeAdmin(address newAdmin) internal {
        emit IERC1967.AdminChanged(getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is the keccak-256 hash of "eip1967.proxy.beacon" subtracted by 1.
     */
    // solhint-disable-next-line private-vars-leading-underscore
    bytes32 internal constant BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Returns the current beacon.
     */
    function getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the ERC-1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        if (newBeacon.code.length == 0) {
            revert ERC1967InvalidBeacon(newBeacon);
        }

        StorageSlot.getAddressSlot(BEACON_SLOT).value = newBeacon;

        address beaconImplementation = IBeacon(newBeacon).implementation();
        if (beaconImplementation.code.length == 0) {
            revert ERC1967InvalidImplementation(beaconImplementation);
        }
    }

    /**
     * @dev Change the beacon and trigger a setup call if data is nonempty.
     * This function is payable only if the setup call is performed, otherwise `msg.value` is rejected
     * to avoid stuck value in the contract.
     *
     * Emits an {IERC1967-BeaconUpgraded} event.
     *
     * CAUTION: Invoking this function has no effect on an instance of {BeaconProxy} since v5, since
     * it uses an immutable beacon without looking at the value of the ERC-1967 beacon slot for
     * efficiency.
     */
    function upgradeBeaconToAndCall(address newBeacon, bytes memory data) internal {
        _setBeacon(newBeacon);
        emit IERC1967.BeaconUpgraded(newBeacon);

        if (data.length > 0) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        } else {
            _checkNonPayable();
        }
    }

    /**
     * @dev Reverts if `msg.value` is not zero. It can be used to avoid `msg.value` stuck in the contract
     * if an upgrade doesn't perform an initialization call.
     */
    function _checkNonPayable() private {
        if (msg.value > 0) {
            revert ERC1967NonPayable();
        }
    }
}

// node_modules/@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol

// OpenZeppelin Contracts (last updated v5.2.0) (proxy/ERC1967/ERC1967Proxy.sol)

/**
 * @dev This contract implements an upgradeable proxy. It is upgradeable because calls are delegated to an
 * implementation address that can be changed. This address is stored in storage in the location specified by
 * https://eips.ethereum.org/EIPS/eip-1967[ERC-1967], so that it doesn't conflict with the storage layout of the
 * implementation behind the proxy.
 */
contract ERC1967Proxy is Proxy {
    /**
     * @dev Initializes the upgradeable proxy with an initial implementation specified by `implementation`.
     *
     * If `_data` is nonempty, it's used as data in a delegate call to `implementation`. This will typically be an
     * encoded function call, and allows initializing the storage of the proxy like a Solidity constructor.
     *
     * Requirements:
     *
     * - If `data` is empty, `msg.value` must be zero.
     */
    constructor(address implementation, bytes memory _data) payable {
        ERC1967Utils.upgradeToAndCall(implementation, _data);
    }

    /**
     * @dev Returns the current implementation address.
     *
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by ERC-1967) using
     * the https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`
     */
    function _implementation() internal view virtual override returns (address) {
        return ERC1967Utils.getImplementation();
    }
}

// node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol

// OpenZeppelin Contracts (last updated v5.3.0) (proxy/utils/UUPSUpgradeable.sol)

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 */
abstract contract UUPSUpgradeable is Initializable, IERC1822Proxiable {
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    address private immutable __self = address(this);

    /**
     * @dev The version of the upgrade interface of the contract. If this getter is missing, both `upgradeTo(address)`
     * and `upgradeToAndCall(address,bytes)` are present, and `upgradeTo` must be used if no function should be called,
     * while `upgradeToAndCall` will invoke the `receive` function if the second argument is the empty byte string.
     * If the getter returns `"5.0.0"`, only `upgradeToAndCall(address,bytes)` is present, and the second argument must
     * be the empty byte string if no function should be called, making it impossible to invoke the `receive` function
     * during an upgrade.
     */
    string public constant UPGRADE_INTERFACE_VERSION = "5.0.0";

    /**
     * @dev The call is from an unauthorized context.
     */
    error UUPSUnauthorizedCallContext();

    /**
     * @dev The storage `slot` is unsupported as a UUID.
     */
    error UUPSUnsupportedProxiableUUID(bytes32 slot);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC-1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC-1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        _checkProxy();
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        _checkNotDelegated();
        _;
    }

    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev Implementation of the ERC-1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate the implementation's compatibility when performing an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual notDelegated returns (bytes32) {
        return ERC1967Utils.IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     *
     * @custom:oz-upgrades-unsafe-allow-reachable delegatecall
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) public payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data);
    }

    /**
     * @dev Reverts if the execution is not performed via delegatecall or the execution
     * context is not of a proxy with an ERC-1967 compliant implementation pointing to self.
     */
    function _checkProxy() internal view virtual {
        if (
            address(this) == __self || // Must be called through delegatecall
            ERC1967Utils.getImplementation() != __self // Must be called through an active proxy
        ) {
            revert UUPSUnauthorizedCallContext();
        }
    }

    /**
     * @dev Reverts if the execution is performed via delegatecall.
     * See {notDelegated}.
     */
    function _checkNotDelegated() internal view virtual {
        if (address(this) != __self) {
            // Must not be called through delegatecall
            revert UUPSUnauthorizedCallContext();
        }
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev Performs an implementation upgrade with a security check for UUPS proxies, and additional setup call.
     *
     * As a security check, {proxiableUUID} is invoked in the new implementation, and the return value
     * is expected to be the implementation slot in ERC-1967.
     *
     * Emits an {IERC1967-Upgraded} event.
     */
    function _upgradeToAndCallUUPS(address newImplementation, bytes memory data) private {
        try IERC1822Proxiable(newImplementation).proxiableUUID() returns (bytes32 slot) {
            if (slot != ERC1967Utils.IMPLEMENTATION_SLOT) {
                revert UUPSUnsupportedProxiableUUID(slot);
            }
            ERC1967Utils.upgradeToAndCall(newImplementation, data);
        } catch {
            // The implementation is not UUPS
            revert ERC1967Utils.ERC1967InvalidImplementation(newImplementation);
        }
    }
}

// lib/sdai/src/l2/SUsds.sol

/// SUsds.sol -- SUsds token

// Copyright (C) 2017, 2018, 2019 dbrock, rain, mrchico
// Copyright (C) 2024 Dai Foundation
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

interface IERC1271_0 {
    function isValidSignature(
        bytes32,
        bytes memory
    ) external view returns (bytes4);
}

contract SUsds is UUPSUpgradeable {
    mapping (address => uint256) public wards;

    // --- ERC20 Data ---
    string  public constant name     = "Savings USDS";
    string  public constant symbol   = "sUSDS";
    string  public constant version  = "1";
    uint8   public constant decimals = 18;
    uint256 public totalSupply;

    mapping (address => uint256)                      public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => uint256)                      public nonces;

    // --- Events ---
    event Rely(address indexed usr);
    event Deny(address indexed usr);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    // --- EIP712 niceties ---
    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    modifier auth {
        require(wards[msg.sender] == 1, "SUsds/not-authorized");
        _;
    }

    constructor() {
        _disableInitializers(); // Avoid initializing in the context of the implementation
    }

    // --- Upgradability ---

    function initialize() initializer external {
        __UUPSUpgradeable_init();

        wards[msg.sender] = 1;
        emit Rely(msg.sender);
    }

    function _authorizeUpgrade(address newImplementation) internal override auth {}

    function getImplementation() external view returns (address) {
        return ERC1967Utils.getImplementation();
    }

    function _calculateDomainSeparator(uint256 chainId) private view returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                chainId,
                address(this)
            )
        );
    }

    function DOMAIN_SEPARATOR() external view returns (bytes32) {
        return _calculateDomainSeparator(block.chainid);
    }

    // --- Administration ---
    function rely(address usr) external auth {
        wards[usr] = 1;
        emit Rely(usr);
    }

    function deny(address usr) external auth {
        wards[usr] = 0;
        emit Deny(usr);
    }

    // --- ERC20 Mutations ---
    function transfer(address to, uint256 value) external returns (bool) {
        require(to != address(0) && to != address(this), "SUsds/invalid-address");
        uint256 balance = balanceOf[msg.sender];
        require(balance >= value, "SUsds/insufficient-balance");

        unchecked {
            balanceOf[msg.sender] = balance - value;
            balanceOf[to] += value; // note: we don't need an overflow check here b/c sum of all balances == totalSupply
        }

        emit Transfer(msg.sender, to, value);

        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        require(to != address(0) && to != address(this), "SUsds/invalid-address");
        uint256 balance = balanceOf[from];
        require(balance >= value, "SUsds/insufficient-balance");

        if (from != msg.sender) {
            uint256 allowed = allowance[from][msg.sender];
            if (allowed != type(uint256).max) {
                require(allowed >= value, "SUsds/insufficient-allowance");

                unchecked {
                    allowance[from][msg.sender] = allowed - value;
                }
            }
        }

        unchecked {
            balanceOf[from] = balance - value;
            balanceOf[to] += value; // note: we don't need an overflow check here b/c sum of all balances == totalSupply
        }

        emit Transfer(from, to, value);

        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;
    }

    // --- Mint/Burn ---
    function mint(address to, uint256 value) external auth {
        require(to != address(0) && to != address(this), "SUsds/invalid-address");
        unchecked {
            balanceOf[to] = balanceOf[to] + value; // note: we don't need an overflow check here b/c balanceOf[to] <= totalSupply and there is an overflow check below
        }
        totalSupply = totalSupply + value;

        emit Transfer(address(0), to, value);
    }

    function burn(address from, uint256 value) external {
        uint256 balance = balanceOf[from];
        require(balance >= value, "SUsds/insufficient-balance");

        if (from != msg.sender) {
            uint256 allowed = allowance[from][msg.sender];
            if (allowed != type(uint256).max) {
                require(allowed >= value, "SUsds/insufficient-allowance");

                unchecked {
                    allowance[from][msg.sender] = allowed - value;
                }
            }
        }

        unchecked {
            balanceOf[from] = balance - value; // note: we don't need overflow checks b/c require(balance >= value) and balance <= totalSupply
            totalSupply     = totalSupply - value;
        }

        emit Transfer(from, address(0), value);
    }

    // --- Approve by signature ---
    function _isValidSignature(
        address signer,
        bytes32 digest,
        bytes memory signature
    ) internal view returns (bool valid) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            if (signer == ecrecover(digest, v, r, s)) {
                return true;
            }
        }

        if (signer.code.length > 0) {
            (bool success, bytes memory result) = signer.staticcall(
                abi.encodeCall(IERC1271_0.isValidSignature, (digest, signature))
            );
            valid = (success &&
                result.length == 32 &&
                abi.decode(result, (bytes4)) == IERC1271_0.isValidSignature.selector);
        }
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        bytes memory signature
    ) public {
        require(block.timestamp <= deadline, "SUsds/permit-expired");
        require(owner != address(0), "SUsds/invalid-owner");

        uint256 nonce;
        unchecked { nonce = nonces[owner]++; }

        bytes32 digest =
            keccak256(abi.encodePacked(
                "\x19\x01",
                _calculateDomainSeparator(block.chainid),
                keccak256(abi.encode(
                    PERMIT_TYPEHASH,
                    owner,
                    spender,
                    value,
                    nonce,
                    deadline
                ))
            ));

        require(_isValidSignature(owner, digest, signature), "SUsds/invalid-permit");

        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        permit(owner, spender, value, deadline, abi.encodePacked(r, s, v));
    }
}

// lib/usds/src/Usds.sol

/// Usds.sol -- Usds token

// Copyright (C) 2017, 2018, 2019 dbrock, rain, mrchico
// Copyright (C) 2023 Dai Foundation
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

interface IERC1271_1 {
    function isValidSignature(
        bytes32,
        bytes memory
    ) external view returns (bytes4);
}

contract Usds is UUPSUpgradeable {
    mapping (address => uint256) public wards;

    // --- ERC20 Data ---
    string  public constant name     = "USDS Stablecoin";
    string  public constant symbol   = "USDS";
    string  public constant version  = "1";
    uint8   public constant decimals = 18;
    uint256 public totalSupply;

    mapping (address => uint256)                      public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => uint256)                      public nonces;

    // --- Events ---
    event Rely(address indexed usr);
    event Deny(address indexed usr);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    // --- EIP712 niceties ---
    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    modifier auth {
        require(wards[msg.sender] == 1, "Usds/not-authorized");
        _;
    }

    constructor() {
        _disableInitializers(); // Avoid initializing in the context of the implementation
    }

    // --- Upgradability ---

    function initialize() initializer external {
        __UUPSUpgradeable_init();

        wards[msg.sender] = 1;
        emit Rely(msg.sender);
    }

    function _authorizeUpgrade(address newImplementation) internal override auth {}

    function getImplementation() external view returns (address) {
        return ERC1967Utils.getImplementation();
    }

    function _calculateDomainSeparator(uint256 chainId) private view returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                chainId,
                address(this)
            )
        );
    }

    function DOMAIN_SEPARATOR() external view returns (bytes32) {
        return _calculateDomainSeparator(block.chainid);
    }

    // --- Administration ---
    function rely(address usr) external auth {
        wards[usr] = 1;
        emit Rely(usr);
    }

    function deny(address usr) external auth {
        wards[usr] = 0;
        emit Deny(usr);
    }

    // --- ERC20 Mutations ---
    function transfer(address to, uint256 value) external returns (bool) {
        require(to != address(0) && to != address(this), "Usds/invalid-address");
        uint256 balance = balanceOf[msg.sender];
        require(balance >= value, "Usds/insufficient-balance");

        unchecked {
            balanceOf[msg.sender] = balance - value;
            balanceOf[to] += value; // note: we don't need an overflow check here b/c sum of all balances == totalSupply
        }

        emit Transfer(msg.sender, to, value);

        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        require(to != address(0) && to != address(this), "Usds/invalid-address");
        uint256 balance = balanceOf[from];
        require(balance >= value, "Usds/insufficient-balance");

        if (from != msg.sender) {
            uint256 allowed = allowance[from][msg.sender];
            if (allowed != type(uint256).max) {
                require(allowed >= value, "Usds/insufficient-allowance");

                unchecked {
                    allowance[from][msg.sender] = allowed - value;
                }
            }
        }

        unchecked {
            balanceOf[from] = balance - value;
            balanceOf[to] += value; // note: we don't need an overflow check here b/c sum of all balances == totalSupply
        }

        emit Transfer(from, to, value);

        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;
    }

    // --- Mint/Burn ---
    function mint(address to, uint256 value) external auth {
        require(to != address(0) && to != address(this), "Usds/invalid-address");
        unchecked {
            balanceOf[to] = balanceOf[to] + value; // note: we don't need an overflow check here b/c balanceOf[to] <= totalSupply and there is an overflow check below
        }
        totalSupply = totalSupply + value;

        emit Transfer(address(0), to, value);
    }

    function burn(address from, uint256 value) external {
        uint256 balance = balanceOf[from];
        require(balance >= value, "Usds/insufficient-balance");

        if (from != msg.sender) {
            uint256 allowed = allowance[from][msg.sender];
            if (allowed != type(uint256).max) {
                require(allowed >= value, "Usds/insufficient-allowance");

                unchecked {
                    allowance[from][msg.sender] = allowed - value;
                }
            }
        }

        unchecked {
            balanceOf[from] = balance - value; // note: we don't need overflow checks b/c require(balance >= value) and balance <= totalSupply
            totalSupply     = totalSupply - value;
        }

        emit Transfer(from, address(0), value);
    }

    // --- Approve by signature ---
    function _isValidSignature(
        address signer,
        bytes32 digest,
        bytes memory signature
    ) internal view returns (bool valid) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            if (signer == ecrecover(digest, v, r, s)) {
                return true;
            }
        }

        if (signer.code.length > 0) {
            (bool success, bytes memory result) = signer.staticcall(
                abi.encodeCall(IERC1271_1.isValidSignature, (digest, signature))
            );
            valid = (success &&
                result.length == 32 &&
                abi.decode(result, (bytes4)) == IERC1271_1.isValidSignature.selector);
        }
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        bytes memory signature
    ) public {
        require(block.timestamp <= deadline, "Usds/permit-expired");
        require(owner != address(0), "Usds/invalid-owner");

        uint256 nonce;
        unchecked { nonce = nonces[owner]++; }

        bytes32 digest =
            keccak256(abi.encodePacked(
                "\x19\x01",
                _calculateDomainSeparator(block.chainid),
                keccak256(abi.encode(
                    PERMIT_TYPEHASH,
                    owner,
                    spender,
                    value,
                    nonce,
                    deadline
                ))
            ));

        require(_isValidSignature(owner, digest, signature), "Usds/invalid-permit");

        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        permit(owner, spender, value, deadline, abi.encodePacked(r, s, v));
    }
}

// lib/lz-governance-relay/lib/dss-test/lib/dss-interfaces/src/Interfaces.sol

// MIP21 Abstracts

// Partial DSS Abstracts

// lib/lz-governance-relay/lib/dss-test/src/ScriptTools.sol
// SPDX-FileCopyrightText: © 2022 Dai Foundation <www.daifoundation.org>

//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

/**
 * @title Script Tools
 * @dev Contains opinionated tools used in scripts.
 */
library ScriptTools {

    VmSafe private constant vm = VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))));

    string internal constant DEFAULT_DELIMITER = ",";
    string internal constant DELIMITER_OVERRIDE = "DSSTEST_ARRAY_DELIMITER";
    string internal constant EXPORT_JSON_KEY = "EXPORTS";

    function getRootChainId() internal view returns (uint256) {
        return vm.envUint("FOUNDRY_ROOT_CHAINID");
    }

    function readInput(string memory name) internal view returns (string memory) {
        string memory root = vm.projectRoot();
        return readInput(root, name);
    }

    function readInput(string memory root, string memory name) internal view returns (string memory) {
        string memory chainInputFolder = string(abi.encodePacked("/script/input/", vm.toString(getRootChainId()), "/"));
        return vm.readFile(string(abi.encodePacked(root, chainInputFolder, name, ".json")));
    }

    function readOutput(string memory name, uint256 timestamp) internal view returns (string memory) {
        string memory root = vm.projectRoot();
        string memory chainOutputFolder = string(abi.encodePacked("/script/output/", vm.toString(getRootChainId()), "/"));
        return vm.readFile(string(abi.encodePacked(root, chainOutputFolder, name, "-", vm.toString(timestamp), ".json")));
    }

    function readOutput(string memory name) internal view returns (string memory) {
        string memory root = vm.projectRoot();
        string memory chainOutputFolder = string(abi.encodePacked("/script/output/", vm.toString(getRootChainId()), "/"));
        return vm.readFile(string(abi.encodePacked(root, chainOutputFolder, name, "-latest.json")));
    }

    /**
     * @notice Use standard environment variables to load config.
     * @dev Will first check FOUNDRY_SCRIPT_CONFIG_TEXT for raw json text.
     *      Falls back to FOUNDRY_SCRIPT_CONFIG for a standard file definition.
     *      Finally will fall back to the given string `name`.
     * @param name The default config file to load if no environment variables are set.
     * @return config The raw json text of the config.
     */
    function loadConfig(string memory name) internal view returns (string memory config) {
        config = vm.envOr("FOUNDRY_SCRIPT_CONFIG_TEXT", string(""));
        if (eq(config, "")) {
            config = readInput(vm.envOr("FOUNDRY_SCRIPT_CONFIG", name));
        }
    }

    /**
     * @notice Use standard environment variables to load config.
     * @dev Will first check FOUNDRY_SCRIPT_CONFIG_TEXT for raw json text.
     *      Falls back to FOUNDRY_SCRIPT_CONFIG for a standard file definition.
     *      Finally will revert if no environment variables are set.
     * @return config The raw json text of the config.
     */
    function loadConfig() internal view returns (string memory config) {
        config = vm.envOr("FOUNDRY_SCRIPT_CONFIG_TEXT", string(""));
        if (eq(config, "")) {
            config = readInput(vm.envString("FOUNDRY_SCRIPT_CONFIG"));
        }
    }

    /**
     * @notice Use standard environment variables to load dependencies.
     * @dev Will first check FOUNDRY_SCRIPT_DEPS_TEXT for raw json text.
     *      Falls back to FOUNDRY_SCRIPT_DEPS for a standard file definition.
     *      Finally will fall back to the given string `name`.
     * @param name The default dependency file to load if no environment variables are set.
     * @return dependencies The raw json text of the dependencies.
     */
    function loadDependencies(string memory name) internal view returns (string memory dependencies) {
        dependencies = vm.envOr("FOUNDRY_SCRIPT_DEPS_TEXT", string(""));
        if (eq(dependencies, "")) {
            dependencies = readOutput(vm.envOr("FOUNDRY_SCRIPT_DEPS", name));
        }
    }

    /**
     * @notice Use standard environment variables to load dependencies.
     * @dev Will first check FOUNDRY_SCRIPT_DEPS_TEXT for raw json text.
     *      Falls back to FOUNDRY_SCRIPT_DEPS for a standard file definition.
     *      Finally will revert if no environment variables are set.
     * @return dependencies The raw json text of the dependencies.
     */
    function loadDependencies() internal view returns (string memory dependencies) {
        dependencies = vm.envOr("FOUNDRY_SCRIPT_DEPS_TEXT", string(""));
        if (eq(dependencies, "")) {
            dependencies = readOutput(vm.envString("FOUNDRY_SCRIPT_DEPS"));
        }
    }

    /**
     * @notice Used to export important contracts to higher level deploy scripts.
     *         Note waiting on Foundry to have better primitives, but roll our own for now.
     * @dev Requires FOUNDRY_EXPORTS_NAME to be set.
     * @param label The label of the address.
     * @param addr The address to export.
     */
    function exportContract(string memory label, address addr) internal {
        exportContract(vm.envString("FOUNDRY_EXPORTS_NAME"), label, addr);
    }

    /**
     * @notice Used to export important contracts to higher level deploy scripts.
     *         Note waiting on Foundry to have better primitives, but roll our own for now.
     * @dev Set FOUNDRY_EXPORTS_NAME to override the name of the json file.
     * @param name The name to give the json file.
     * @param label The label of the address.
     * @param addr The address to export.
     */
    function exportContract(string memory name, string memory label, address addr) internal {
        name = vm.envOr("FOUNDRY_EXPORTS_NAME", name);
        string memory json = vm.serializeAddress(string(abi.encodePacked(EXPORT_JSON_KEY, "_", name)), label, addr);
        _doExport(name, json);
    }

    /**
     * @notice Used to export important contracts to higher level deploy scripts. Specifically,
     *         this function exports an array of contracts under the same key (label).
     *         Note waiting on Foundry to have better primitives, but roll our own for now.
     * @dev Set FOUNDRY_EXPORTS_NAME to override the name of the json file.
     * @param name The name to give the json file.
     * @param label The label of the addresses.
     * @param addr The addresses to export.
     */
    function exportContracts(string memory name, string memory label, address[] memory addr) internal {
        name = vm.envOr("FOUNDRY_EXPORTS_NAME", name);
        string memory json = vm.serializeAddress(string(abi.encodePacked(EXPORT_JSON_KEY, "_", name)), label, addr);
        _doExport(name, json);
    }

    /**
     * @notice Used to export important values to higher level deploy scripts.
     *         Note waiting on Foundry to have better primitives, but roll our own for now.
     * @dev Requires FOUNDRY_EXPORTS_NAME to be set.
     * @param label The label of the address.
     * @param val The value to export.
     */
    function exportValue(string memory label, uint256 val) internal {
        exportValue(vm.envString("FOUNDRY_EXPORTS_NAME"), label, val);
    }

    /**
     * @notice Used to export important values to higher level deploy scripts.
     *         Note waiting on Foundry to have better primitives, but roll our own for now.
     * @dev Set FOUNDRY_EXPORTS_NAME to override the name of the json file.
     * @param name The name to give the json file.
     * @param label The label of the address.
     * @param val The value to export.
     */
    function exportValue(string memory name, string memory label, uint256 val) internal {
        name = vm.envOr("FOUNDRY_EXPORTS_NAME", name);
        string memory json = vm.serializeUint(string(abi.encodePacked(EXPORT_JSON_KEY, "_", name)), label, val);
        _doExport(name, json);
    }

    /**
     * @notice Used to export important values to higher level deploy scripts.
     *         Note waiting on Foundry to have better primitives, but roll our own for now.
     * @dev Requires FOUNDRY_EXPORTS_NAME to be set.
     * @param label The label of the address.
     * @param val The value to export.
     */
    function exportValue(string memory label, string memory val) internal {
        exportValue(vm.envString("FOUNDRY_EXPORTS_NAME"), label, val);
    }

    /**
     * @notice Used to export important values to higher level deploy scripts.
     *         Note waiting on Foundry to have better primitives, but roll our own for now.
     * @dev Set FOUNDRY_EXPORTS_NAME to override the name of the json file.
     * @param name The name to give the json file.
     * @param label The label of the address.
     * @param val The value to export.
     */
    function exportValue(string memory name, string memory label, string memory val) internal {
        name = vm.envOr("FOUNDRY_EXPORTS_NAME", name);
        string memory json = vm.serializeString(string(abi.encodePacked(EXPORT_JSON_KEY, "_", name)), label, val);
        _doExport(name, json);
    }

    /**
     * @dev Common logic to export JSON files.
     * @param name The name to give the json file
     * @param json The serialized json object to export.
     */
    function _doExport(string memory name, string memory json) internal {
        string memory root = vm.projectRoot();
        string memory chainOutputFolder = string(abi.encodePacked("/script/output/", vm.toString(getRootChainId()), "/"));
        vm.writeJson(json, string(abi.encodePacked(root, chainOutputFolder, name, "-", vm.toString(block.timestamp), ".json")));
        if (vm.envOr("FOUNDRY_EXPORTS_OVERWRITE_LATEST", false)) {
            vm.writeJson(json, string(abi.encodePacked(root, chainOutputFolder, name, "-latest.json")));
        }
    }

    /**
     * @notice It's common to define strings as bytes32 (such as for ilks)
     */
    function stringToBytes32(string memory source) internal pure returns (bytes32 result) {
        bytes memory emptyStringTest = bytes(source);
        if (emptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }

    /**
     * @notice Convert an ilk to a chainlog key by replacing all dashes with underscores.
     *         Ex) Convert "ETH-A" to "ETH_A"
     */
    function ilkToChainlogFormat(bytes32 ilk) internal pure returns (string memory) {
        uint256 len = 0;
        for (; len < 32; len++) {
            if (uint8(ilk[len]) == 0x00) break;
        }
        bytes memory result = new bytes(len);
        for (uint256 i = 0; i < len; i++) {
            uint8 b = uint8(ilk[i]);
            if (b == 0x2d) result[i] = bytes1(0x5f);
            else result[i] = bytes1(b);
        }
        return string(result);
    }

    function eq(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }

    function switchOwner(address base, address deployer, address newOwner) internal {
        if (deployer == newOwner) return;
        require(WardsAbstract(base).wards(deployer) == 1, "deployer-not-authed");
        WardsAbstract(base).rely(newOwner);
        WardsAbstract(base).deny(deployer);
    }

    // Read config variable, but allow for an environment variable override

    function readUint(string memory json, string memory key, string memory envKey) internal view returns (uint256) {
        return vm.envOr(envKey, stdJson.readUint(json, key));
    }

    function readUintArray(string memory json, string memory key, string memory envKey) internal view returns (uint256[] memory) {
        return vm.envOr(envKey, vm.envOr(DELIMITER_OVERRIDE, DEFAULT_DELIMITER), stdJson.readUintArray(json, key));
    }

    function readInt(string memory json, string memory key, string memory envKey) internal view returns (int256) {
        return vm.envOr(envKey, stdJson.readInt(json, key));
    }

    function readIntArray(string memory json, string memory key, string memory envKey) internal view returns (int256[] memory) {
        return vm.envOr(envKey, vm.envOr(DELIMITER_OVERRIDE, DEFAULT_DELIMITER), stdJson.readIntArray(json, key));
    }

    function readBytes32(string memory json, string memory key, string memory envKey) internal view returns (bytes32) {
        return vm.envOr(envKey, stdJson.readBytes32(json, key));
    }

    function readBytes32Array(string memory json, string memory key, string memory envKey) internal view returns (bytes32[] memory) {
        return vm.envOr(envKey, vm.envOr(DELIMITER_OVERRIDE, DEFAULT_DELIMITER), stdJson.readBytes32Array(json, key));
    }

    function readString(string memory json, string memory key, string memory envKey) internal view returns (string memory) {
        return vm.envOr(envKey, stdJson.readString(json, key));
    }

    function readStringArray(string memory json, string memory key, string memory envKey) internal view returns (string[] memory) {
        return vm.envOr(envKey, vm.envOr(DELIMITER_OVERRIDE, DEFAULT_DELIMITER), stdJson.readStringArray(json, key));
    }

    function readAddress(string memory json, string memory key, string memory envKey) internal view returns (address) {
        return vm.envOr(envKey, stdJson.readAddress(json, key));
    }

    function readAddressArray(string memory json, string memory key, string memory envKey) internal view returns (address[] memory) {
        return vm.envOr(envKey, vm.envOr(DELIMITER_OVERRIDE, DEFAULT_DELIMITER), stdJson.readAddressArray(json, key));
    }

    function readBool(string memory json, string memory key, string memory envKey) internal view returns (bool) {
        return vm.envOr(envKey, stdJson.readBool(json, key));
    }

    function readBoolArray(string memory json, string memory key, string memory envKey) internal view returns (bool[] memory) {
        return vm.envOr(envKey, vm.envOr(DELIMITER_OVERRIDE, DEFAULT_DELIMITER), stdJson.readBoolArray(json, key));
    }

    function readBytes(string memory json, string memory key, string memory envKey) internal view returns (bytes memory) {
        return vm.envOr(envKey, stdJson.readBytes(json, key));
    }

    function readBytesArray(string memory json, string memory key, string memory envKey) internal view returns (bytes[] memory) {
        return vm.envOr(envKey, vm.envOr(DELIMITER_OVERRIDE, DEFAULT_DELIMITER), stdJson.readBytesArray(json, key));
    }

}

// lib/sdai/deploy/l2/SUsdsDeploy.sol

// Copyright (C) 2024 Dai Foundation
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

library SUsdsDeploy {
    function deploy(
        address deployer,
        address owner
    ) internal returns (SUsdsInstance memory instance) {
        address _sUsdsImp = address(new SUsds());
        address _sUsds = address((new ERC1967Proxy(_sUsdsImp, abi.encodeCall(SUsds.initialize, ()))));
        ScriptTools.switchOwner(_sUsds, deployer, owner);

        instance.sUsds    = _sUsds;
        instance.sUsdsImp = _sUsdsImp;
    }
}

// lib/usds/deploy/UsdsDeploy.sol
// SPDX-FileCopyrightText: © 2023 Dai Foundation <www.daifoundation.org>

//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

interface DaiJoinLike_1 {
    function vat() external view returns (address);
}

library UsdsDeploy {
    function deploy(
        address deployer,
        address owner,
        address daiJoin
    ) internal returns (UsdsInstance memory instance) {
        address _usdsImp = address(new Usds());
        address _usds = address((new ERC1967Proxy(_usdsImp, abi.encodeCall(Usds.initialize, ()))));
        ScriptTools.switchOwner(_usds, deployer, owner);

        address _usdsJoin = address(new UsdsJoin(DaiJoinLike_1(daiJoin).vat(), _usds));
        address _daiUsds = address(new DaiUsds(daiJoin, _usdsJoin));

        instance.usds     = _usds;
        instance.usdsImp  = _usdsImp;
        instance.usdsJoin = _usdsJoin;
        instance.daiUsds  = _daiUsds;
    }

    function deployL2(
        address deployer,
        address owner
    ) internal returns (UsdsL2Instance memory instance) {
        address _usdsImp = address(new Usds());
        address _usds = address((new ERC1967Proxy(_usdsImp, abi.encodeCall(Usds.initialize, ()))));
        ScriptTools.switchOwner(_usds, deployer, owner);

        instance.usds     = _usds;
        instance.usdsImp  = _usdsImp;
    }
}

// script/mocks/TokenDeployFlat.sol (bundle)

