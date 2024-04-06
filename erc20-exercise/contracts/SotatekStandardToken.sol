// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract SotatekStandardToken {
    mapping(address => uint) private _balances;
    mapping(address => mapping(address => uint)) private _allowances;
    mapping(address => bool) private _blacklist;

    uint public constant TAX_PERCENTAGE = 5000;

    uint public totalSupply;
    uint public maxSupply;

    string public name;
    string public symbol;
    address public owner;
    address public treasury;

    event Transfer(address sender, address receiver, uint amount, uint tax);
    event Approve(address approver, address spender, uint amount);
    event UpdateTreasury(address oldTreasury, address newTreasury);

    constructor(
        string memory _name,
        string memory _symbol,
        uint _maxSupply,
        address _owner,
        address _treasury
    ) {
        name = _name;
        symbol = _symbol;
        maxSupply = _maxSupply;
        owner = _owner;
        treasury = _treasury;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "SotatekStandardToken::InvalidOwner");
        _;
    }
    // ===============================EXTERNAL FUNCTION==================================
    function transfer(address _to, uint _amount) external returns (bool) {
        _transfer(msg.sender, _to, _amount);
        return true;
    }

    function approve(address _spender, uint _amount) external returns (bool) {
        _approve(msg.sender, _spender, _amount);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint _amount
    ) external returns (bool) {
        _spendAllowance(_from, msg.sender, _amount);
        _transfer(_from, _to, _amount);
        return true;
    }

    function mint(
        address _user,
        uint _amount
    ) external onlyOwner returns (bool) {
        _mint(_user, _amount);
        return true;
    }

    function burn(uint _amount) external onlyOwner returns (bool) {
        _burn(msg.sender, _amount);
        return true;
    }

    function blockUser(address _user) external onlyOwner returns (bool) {
        _block(_user);
        return true;
    }

    function updateTreasury(address _treasury) external onlyOwner returns (bool) {
        _updateTreasury(_treasury);
        return true;
    }

    // ==============================PUBLIC VIEW FUNCTION===================================

    function decimals() public view returns (uint8) {
        return 18;
    }

    function balanceOf(address _user) public view returns (uint) {
        return _balances[_user];
    }

    function allowance(
        address _approver,
        address _spender
    ) public view returns (uint) {
        return _allowances[_approver][_spender];
    }

    function hasBlocked(address _user) public view returns (bool) {
        return _blacklist[_user];
    }

    // ============================INTERNAL FUNCTION=====================================
    function _transfer(address _from, address _to, uint _amount) internal {
        require(_from != address(0), "SotatekStandardToken::InvalidSender");
        require(_from != address(0), "SotatekStandardToken::InvalidRecei");
        require(!_blacklist[_from], "SotatekStandardToken::SendInBlacklist");
        require(!_blacklist[_to], "SotatekStandardToken::ReceiveInBlacklist");
        require(
            _balances[_from] >= _amount,
            "SotatekStandardToken::InsufficientBalance"
        );
        uint tax = (_amount * TAX_PERCENTAGE) / 100000;
        uint remain = _amount - tax;
        _balances[_from] -= _amount;
        _balances[treasury] += tax;
        _balances[_to] += remain;
        emit Transfer(_from, _to, _amount, tax);
    }

    function _approve(address _from, address _to, uint _amount) internal {
        require(_from != address(0), "SotatekStandardToken::InvalidApprover");
        require(_to != address(0), "SotatekStandardToken::InvalidSpender");
        _allowances[_from][_to] = _amount;
        emit Approve(_from, _to, _amount);
    }

    function _spendAllowance(
        address _approver,
        address _spender,
        uint _amount
    ) internal {
        require(
            _allowances[_approver][_spender] >= _amount,
            "SotatekStandardToken::InsufficientAllowanceBalance"
        );
        _allowances[_approver][_spender] -= _amount;
    }

    function _mint(address _account, uint _amount) internal {
        require(
            _account != address(0),
            "SotatekStandardToken::InvalidBenificiary"
        );
        require(
            totalSupply + _amount <= maxSupply,
            "SotatekStandardToken::OverMaxSupply"
        );
        _balances[_account] += _amount;
        totalSupply += _amount;
        emit Transfer(address(0), _account, _amount, 0);
    }

    function _burn(address _account, uint _amount) internal {
        require(_account != address(0), "SotatekStandardToken::InvalidBurner");
        require(
            _balances[_account] >= _amount,
            "SotatekStandardToken::InsufficientBalance"
        );
        _balances[_account] -= _amount;
        totalSupply -= _amount;
        emit Transfer(_account, address(0), _amount, 0);
    }

    function _block(address _user) internal {
        require(!_blacklist[_user], "SotatekStandardToken::AlreadyInBlacklist");
        _blacklist[_user] = true;
    }

    function _updateTreasury(address _treasury) internal {
        require(_treasury != address(0), "SotatekStandardToken::IvalidTreasury");
        address oldTreasury = treasury;
        treasury = _treasury;
        emit UpdateTreasury(oldTreasury, treasury);
    }
}
