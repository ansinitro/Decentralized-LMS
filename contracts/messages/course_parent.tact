message CostChange {
    newCost: Int as coins;
}

message UpdateGasOverhead {
    newGasOverhead: Int as uint32;
}

message Enrollment {
    studentIIN: String;
}