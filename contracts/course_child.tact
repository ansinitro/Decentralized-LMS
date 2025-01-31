import "@stdlib/deploy";
import "./messages/course_child";

contract CourseChild with Deployable {
    override const storageReserve: Int = ton("0.2");

    courseAddress: Address;
    owner: Address;
    // Cell which will save beginParse().saveUint([0-9], 4)....endParse(); 
    // 12 digit because IIN 12 DIgit 48 bit < 96 bit(string representation)
    ownerIin: String; 
    
    init(courseAddress: Address, owner: Address, ownerIin: String) {
        require(courseAddress == context().sender, "Ty che morosish bratishka");
        self.courseAddress = courseAddress;
        self.owner = owner;
        self.ownerIin = ownerIin;
    }

    // receive(msg: SendAnswer) { // will send direct from wallet
    //     require(context().sender == self.owner, "not from collection");
    //     send(SendParameters{
    //         to: msg.quizAddress,
    //         value: 0,
    //         bounce: false,
    //         mode: SendRemainingValue,
    //         body: StudentAnswer{studentIin: self.ownerIin, 
    //                             studentAddress: self.owner, // will direct 
    //                             studentAnswers: msg.answer}.toCell(),
    //     });
    // }

    receive(msg: Result) {
        emit(Result{quizId: msg.quizId, percent: msg.percent}.toCell());
    }

    receive("Initialize") {
    }

    /////////////////
    //// Getters ////
    /////////////////
    get fun ownerIin(): String {
        return self.ownerIin;
    }

    get fun courseAddress(): Address {
        return self.courseAddress;
    }
}
