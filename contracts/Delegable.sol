// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;


/// @dev Delegable enables users to delegate their account management to other users.
/// Delegable implements addDelegateBySignature, to add delegates using a signature instead of a separate transaction.
contract Delegable {
    event Delegate(address indexed user, address indexed delegate, bool enabled);

    bytes32 public constant SIGNATURE_TYPEHASH = keccak256("Signature(address user,address delegate,uint256 nonce,uint256 deadline)"); // 0x0d077601844dd17f704bafff948229d27f33b57445915754dfe3d095fda2beb7;
    bytes32 public immutable DELEGABLE_DOMAIN;
    mapping(address => uint) public signatureCount;

    mapping(address => mapping(address => bool)) public delegated;

    constructor () {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }

        DELEGABLE_DOMAIN = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                keccak256(bytes('USMFUM')),
                keccak256(bytes('1')),
                chainId,
                address(this)
            )
        );
    }

    /// @dev Require that msg.sender is the account holder or a delegate
    modifier onlyHolderOrDelegate(address holder, string memory errorMessage) {
        require(
            msg.sender == holder || delegated[holder][msg.sender],
            errorMessage
        );
        _;
    }

    /// @dev Enable a delegate to act on the behalf of caller
    function addDelegate(address delegate) public {
        _addDelegate(msg.sender, delegate);
    }

    /// @dev Stop a delegate from acting on the behalf of caller
    function revokeDelegate(address delegate) public {
        _revokeDelegate(msg.sender, delegate);
    }

    /// @dev Allow a delegate to renounce to its delegation
    function renounceDelegate(address user) public {
        _revokeDelegate(user, msg.sender);
    }

    /// @dev Add a delegate through an encoded signature
    function addDelegateBySignature(address user, address delegate, uint deadline, uint8 v, bytes32 r, bytes32 s) public {
        require(deadline >= block.timestamp, 'Delegable: Signature expired');

        bytes32 hashStruct = keccak256(
            abi.encode(
                SIGNATURE_TYPEHASH,
                user,
                delegate,
                signatureCount[user]++,
                deadline
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DELEGABLE_DOMAIN,
                hashStruct
            )
        );
        address signer = ecrecover(digest, v, r, s);
        require(
            signer != address(0) && signer == user,
            'Delegable: Invalid signature'
        );

        _addDelegate(user, delegate);
    }

    /// @dev Enable a delegate to act on the behalf of an user
    function _addDelegate(address user, address delegate) internal {
        if (!delegated[user][delegate]) {
            delegated[user][delegate] = true;
            emit Delegate(user, delegate, true);
        }
    }

    /// @dev Stop a delegate from acting on the behalf of an user
    function _revokeDelegate(address user, address delegate) internal {
        if (delegated[user][delegate]) {
            delegated[user][delegate] = false;
            emit Delegate(user, delegate, false);
        }
    }
}
