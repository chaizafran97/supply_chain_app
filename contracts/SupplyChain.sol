// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract SupplyChain {

   struct cargo{
    uint256 cargoID;
    uint256 cargoPrice;
    string cargoDetails;
    string cargoLocation;
	string buyer;
	string cargoState;
    }

    address owner;
    cargo[] public Cargo;

    event DeniedAtCustoms(string);
	event AllowedThroughCustoms(string);

	//for future use
    constructor() public {
        owner = msg.sender;
    }

	//initialize cargo, buyer can be left as N/a yet
    function initializeCargo(
        uint256 cargoPrice,
        string memory cargoDetails,
        string memory cargoLocation,
		string memory buyer
    ) public {
		uint cargoID = 0;
		string memory cargoState = "With Seller";
      	Cargo.push(cargo(cargoID,cargoPrice,cargoDetails,cargoLocation,buyer,cargoState));
	 	cargoID++;
    }

	//function that allows us to put the buyer name
	function cargoBought(uint256 _id, string memory _temp) public {
		Cargo[_id].buyer = _temp;
		Cargo[_id].cargoState = "Order Created";
	}

	//meant for customs check, if approved auto ship the cargo
	//needs to have approval of several members before approve
	function customsCheck(uint256 _id, string memory _temp) public returns(string memory){
		if (keccak256(abi.encodePacked((_temp))) == keccak256("Y")){
			emit AllowedThroughCustoms("Customs approved, you can proceed with shipping");//for future use
			cargoShipping(_id);
			return("Customs approved, you can proceed with shipping");
		}
		else {
			emit DeniedAtCustoms("Order was denied by customs");//for future use
			return("Order was denied by customs");//for testing purposes now
		}
	}

	//function that states the cargo is currently shipping
	function cargoShipping(uint256 _id) public {
		Cargo[_id].cargoState = "Order currently shipping";
	}

	//function that states buyer has received
	//an if else statement needs to be added so this state can only be achieved when cargo location and buyer address matches
	function cargoReceieved(uint256 _id) public {
		Cargo[_id].cargoState = "Buyer has received";
	}

	//meant for testing if we can see the cargo
	function viewCargo(uint256 _temp) public view 
	returns(uint256, uint256, string memory, string memory, string memory, string memory){
	return(Cargo[_temp].cargoID, Cargo[_temp].cargoPrice, Cargo[_temp].cargoDetails,
	Cargo[_temp].cargoLocation, Cargo[_temp].buyer, Cargo[_temp].cargoState);
	}

    }