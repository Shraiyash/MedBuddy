// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract MedicalRecords {
    struct Patient {
        string name;
        string patientAddress;
        uint256 phoneNumber;
        uint256 aadharNumber;
        string bloodGroup;
        string role; // Added role field
    }

    struct Doctor {
        string name;
        string doctorAddress;
        uint256 phoneNumber;
        uint256 aadharNumber;
        string bloodGroup;
        string role; // Added role field
    }

    struct Record {
        string data;
        string doctorName;
        uint256 timestamp;
    }

    struct ValidDoctor {
        string name;
        address doctorAddress;
    }

    mapping(address => Patient) public patients;
    mapping(address => Doctor) public doctors;
    mapping(address => mapping(address => Record[])) public records;
    mapping(address => mapping(address => bool)) public hasAccess;
    mapping(address => Record[]) public allRecords;
    mapping(address => ValidDoctor[]) public validDoctors; // List of valid doctors for each patient

    function addPatient(string memory _name, string memory _patientAddress, uint256 _phoneNumber, uint256 _aadharNumber, string memory _bloodGroup, string memory _role) public {
        require(bytes(patients[msg.sender].name).length == 0, "Patient already registered");
        patients[msg.sender] = Patient(_name, _patientAddress, _phoneNumber, _aadharNumber, _bloodGroup, _role);
    }

    function addDoctor(string memory _name, string memory _doctorAddress, uint256 _phoneNumber, uint256 _aadharNumber, string memory _bloodGroup, string memory _role) public {
        require(bytes(doctors[msg.sender].name).length == 0, "Doctor already registered");
        doctors[msg.sender] = Doctor(_name, _doctorAddress, _phoneNumber, _aadharNumber, _bloodGroup, _role);
    }

    function grantAccess(address doctorAddress) public {
        hasAccess[msg.sender][doctorAddress] = true;
        string memory doctorName = doctors[doctorAddress].name;
        ValidDoctor memory newDoctor = ValidDoctor(doctorName, doctorAddress);
        validDoctors[msg.sender].push(newDoctor);
    }

    function revokeAccess(address doctorAddress) public {
        // require(hasAccess[msg.sender][doctorAddress], "Doctor does not have access");
        hasAccess[msg.sender][doctorAddress] = false;
        
        ValidDoctor[] storage patientDoctors = validDoctors[msg.sender];
        for (uint256 i = 0; i < patientDoctors.length; i++) {
            if (patientDoctors[i].doctorAddress == doctorAddress) {
                // Remove the doctor from the list
                if (i != patientDoctors.length - 1) {
                    patientDoctors[i] = patientDoctors[patientDoctors.length - 1];
                }
                patientDoctors.pop();
                break;
            }
        }
    }
    
    function doesUserExist(address userAddress) public view returns (bool) {
        return bytes(patients[userAddress].name).length > 0 || bytes(doctors[userAddress].name).length > 0;
    }

    function addRecord(address patientAddress, string memory _data, string memory _doctorName) public {
        require(hasAccess[patientAddress][msg.sender], "Doctor does not have access");
        Record memory newRecord = Record(_data, _doctorName, block.timestamp);
        records[patientAddress][msg.sender].push(newRecord);
        allRecords[patientAddress].push(newRecord);
        hasAccess[patientAddress][patientAddress] = true;
    }

    function getTimeStamps(address patientAddress) public view returns (uint256[] memory) {
        require(hasAccess[patientAddress][msg.sender], "Doctor does not have access");

        Record[] memory patientRecords = allRecords[patientAddress];
        uint256[] memory timestamps = new uint256[](patientRecords.length);

        for (uint256 i = 0; i < patientRecords.length; i++) {
            timestamps[i] = patientRecords[i].timestamp;
        }

        return timestamps;
    }

    function getDoctorNames(address patientAddress) public view returns (string[] memory) {
        require(hasAccess[patientAddress][msg.sender], "Doctor does not have access");
        Record[] memory patientRecords = allRecords[patientAddress];
        string[] memory doctorNames = new string[](patientRecords.length);

        for (uint256 i = 0; i < patientRecords.length; i++) {
            doctorNames[i] = patientRecords[i].doctorName;
        }
        return doctorNames;
    }

    function getData(address patientAddress) public view returns (string[] memory) {
        require(hasAccess[patientAddress][msg.sender], "Doctor does not have access");
        Record[] memory patientRecords = allRecords[patientAddress];
        string[] memory datas = new string[](patientRecords.length);

        for (uint256 i = 0; i < patientRecords.length; i++) {
            datas[i] = patientRecords[i].data;
        }
        return datas;
    }

    function getValidDoctors(address patientAddress) public view returns (string[] memory, address[] memory) {
        require(hasAccess[patientAddress][msg.sender], "Doctor does not have access");
        ValidDoctor[] memory patientDoctors = validDoctors[patientAddress];
        string[] memory doctorNames = new string[](patientDoctors.length);
        address[] memory doctorAddresses = new address[](patientDoctors.length);

        for (uint256 i = 0; i < patientDoctors.length; i++) {
            doctorNames[i] = patientDoctors[i].name;
            doctorAddresses[i] = patientDoctors[i].doctorAddress;
        }
        return (doctorNames, doctorAddresses);
    }

}
