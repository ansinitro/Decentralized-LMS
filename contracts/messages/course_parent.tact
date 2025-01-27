message CostChange {
    newCost: Int as coins;
}
message UpdateGasOverhead {
    newGasOverhead: Int as uint32;
}

message Enrollment {
    studentIin: String;
}

message EnrollmentEmit {
    studentAddress: Address;
    studentIin: String;
}