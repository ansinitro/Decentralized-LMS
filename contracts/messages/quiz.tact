message StudentGrade {
    studentAddress: Address;
    studentIin: String;
    studentPercent: Int as uint16;
}

message ReturnResult {
    quizId: Int as uint8;
    percent: Int as uint16;
}

message EmitAnswers {
    sender: Address;
    answers: String; // it should be cell which will save beginParse().saveUint(<answer>, 3)....endParse();
}

// message StudentAnswer {
//     studentAddress: Address;
//     studentIin: String;
//     studentAnswers: String;
// }