import "@stdlib/deploy";
import "./messages/quiz";
import "@stdlib/ownable";

contract Quiz with Deployable, Ownable {
    override const storageReserve: Int = ton("0.1");

    id: Int;
    courseAddress: Address;
    owner: Address;
    isOpen: Bool = true;

    init(id: Int, courseAddress: Address) {
        self.id = id;
        self.courseAddress = courseAddress;
        self.owner = context().sender
    }

    receive(msg: StudentAnswer) {
        require(self.isOpen || context().sender == self.owner, "The quiz ended");
                    
        emit(StudentAnswer{studentIin: msg.studentIin, 
                                studentAnswers: msg.studentAnswers}.toCell());

        nativeReserve(self.storageReserve, 0);
        send(SendParameters {
            to: msg.studentAddress,
            value: 0,
            mode: SendRemainingBalance,
            bounce: false,
            body: "Your answers for quiz was received".asComment(),
        });
    }

    receive(msg: StudentGrade) {
        self.requireOwner();
        studentAddress = contractAddress(self.getJettonWalletInit(msg.studentAddress, msg.studentIin));

        send(SendParameters{
            to: studentAddress,
            value: 0,
            mode: SendPayGasSeparately,
            body: ReturnResult{
                courseAddress: self.courseAddress,
                quizId: self.id,
                percent: msg.studentPercent,
            }.toCell(),
        });

        nativeReserve(self.storageReserve, 0);
        self.notify("Answer Successfully sent".asComment());
    }

    receive("Lock") {
        self.requireOwner();
        emit("Lock".asComment());
        self.isOpen = true;
    }

    receive("Unlock") {
        self.requireOwner();
        self.isOpen = false;
    }

    fun getJettonWalletInit(sender: Address, iin: String): StateInit {
        return initOf CourseChild(self.courseAddress, sender, iin);
    }
    
    /////////////////
    //// Getters ////
    ////////////////
    get fun id(): Int {
        return self.id;
    }

    get fun isOpen(): Int {
        return self.id;
    }

    get fun courseAddress(): Address {
        return self.courseAddress;
    }
}

        // quiz = blockchain
        //     .openContract(await Quiz.fromInit(0n, courseParent.address, beginCell()
        //         .storeUint(1, 3)
        //         .storeUint(3, 3)
        //         .storeUint(4, 3)
        //         .storeUint(2, 3)
        //         .storeUint(1, 3)
        //         .asSlice()));