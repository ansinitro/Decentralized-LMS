import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { fromNano, toNano } from '@ton/core';
import { CourseParent } from '../wrappers/CourseParent';
import { CourseChild } from '../wrappers/CourseChild';
import '@ton/test-utils';

const COURSE_COST = toNano(3);
const COURSE_STORAGE_RESERVE = toNano(0.1);

const STUDENT_IIN = "021414510239";

describe('CourseParent', () => {
    let blockchain: Blockchain;
    let educator: SandboxContract<TreasuryContract>;
    let student: SandboxContract<TreasuryContract>;
    let courseParent: SandboxContract<CourseParent>;
    let courseChild: SandboxContract<CourseChild>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();
        educator = await blockchain.treasury('educator');
        student = await blockchain.treasury('student');
        courseParent = blockchain
            .openContract(await CourseParent.fromInit(educator.address, 0n));
        // check how it will act if will created the same contratc but by other guy and will the studentCount change?
        const deployResult = await courseParent.send(
            educator.getSender(),
            {
                value: toNano('0.2'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            }
        );

        await courseParent.send(
            educator.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'CostChange',
                newCost: COURSE_COST,
            }
        );
    });

    /////////////////////
    //// Cost Change ////
    ////////////////////
    it('CourseParent Cost Change owner', async () => {
        const newCost = toNano(5);
        const costChangeResult = await courseParent.send(
            educator.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'CostChange',
                newCost: newCost,
            }
        );
        expect(newCost).toEqual(await courseParent.getCourseCost());
    });

    it('CourseParent Cost Change not owner', async () => {
        const newCost = toNano(1000);
        const costChangeResult = await courseParent.send(
            student.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'CostChange',
                newCost: newCost,
            }
        );

        expect(costChangeResult.transactions).toHaveTransaction({
            from: student.address,
            to: courseParent.address,
            success: false,
        });
    });

    /////////////////////
    //// Enrollment /////
    ////////////////////
    it('CourseParent Enrollment not enogh ton value', async () => {
        const enrollmentResult = await courseParent.send(
            educator.getSender(),
            {
                value: toNano('0.05'),
                bounce: true,
            },
            {
                $$type: 'Enrollment',
                studentIin: STUDENT_IIN,
            }
        );

        expect(enrollmentResult.transactions).toHaveTransaction({
            from: educator.address,
            to: courseParent.address,
            success: false,
        });
    });

    it('CourseParent Enrollment enough ton value', async () => {
        let course_cost = await courseParent.getCourseCost();
        let course_balance_before = await courseParent.getBalance();
        let student_balance_before = await student.getBalance();
        const enrollmentResult = await courseParent.send(
            student.getSender(),
            {
                value: toNano('3.5'),
                bounce: true,
            },
            {
                $$type: 'Enrollment',
                studentIin: STUDENT_IIN,
            }
        );

        courseChild = blockchain
            .openContract(await CourseChild.fromInit(courseParent.address,
                student.address,
                STUDENT_IIN));

        expect(await courseParent.getBalance()).toBeGreaterThanOrEqual(course_balance_before + course_cost);
        expect(await courseParent.getStudentsNumber()).toEqual(1n);

        // console.log(fromNano(student_balance_before - (await student.getBalance()) - toNano(3.1)))
        // console.log(blockchain);
        // console.log(enrollmentResult.externals[0].body.asSlice().loadStringTail());
    });

    it('CourseParent Withdraw Not Owner', async () => {
        const withdrawResult = await courseParent.send(
            student.getSender(),
            {
                value: toNano('0.05'),
                bounce: true,
            },
            'Withdraw'
        );

        expect(withdrawResult.transactions).toHaveTransaction({
            from: student.address,
            to: courseParent.address,
            success: false,
        });
    });

    it('CourseParent Withdraw Owner', async () => {
        let educatorBalanceBefore = await educator.getBalance();
        let courseParentBalanceBefore = await courseParent.getBalance();

        const withdrawResult = await courseParent.send(
            educator.getSender(),
            {
                value: toNano('0.05'),
                bounce: true,
            },
            'Withdraw'
        );
        expect(await courseParent.getBalance()).toEqual(COURSE_STORAGE_RESERVE);
    });

    it('CourseParent Withdraw Owner | Contract balance less than 0.1', async () => {
        await courseParent.send(
            educator.getSender(),
            {
                value: toNano('0.05'),
                bounce: true,
            },
            'Withdraw'
        );

        const fourYearsAfter = (Math.floor(Date.now() / 1000)) + 365 * 24 * 60 * 60 * 4;

        blockchain.now = fourYearsAfter;
        let educatorBalanceBefore = await educator.getBalance(); // 0.1 TON

        await courseParent.send(
            educator.getSender(),
            {
                value: toNano('0.0001'),
                bounce: true,
            },
            'Withdraw'
        );

        expect(await educator.getBalance()).toBeLessThan(educatorBalanceBefore);
        expect(await courseParent.getBalance()).toBeLessThan(COURSE_STORAGE_RESERVE);
    });

});
