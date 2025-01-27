message SendAnswer {
    quizAddress: Address;
    answer: String;
}

message StudentAnswer {
    studentAddress: Address;
    studentIin: String;
    studentAnswers: String;
}

message Result {
    quizId: Int as uint8;
    percent: Int as uint16;
}