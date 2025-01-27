import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { CourseParent } from '../wrappers/CourseParent';
import { CourseChild } from '../wrappers/CourseChild';
import '@ton/test-utils';

const OWNER_IIN = "021414510239";

describe('CourseChild', () => {
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
            .openContract(await CourseParent.fromInit(0n));
        courseChild = blockchain
            .openContract(await CourseChild.fromInit(courseParent.address,
                student.address,
                OWNER_IIN));

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

        const costChangeResult = await courseParent.send(
            educator.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'CostChange',
                newCost: toNano(3),
            }
        );

        const enrollmentResult = await courseParent.send(
            student.getSender(),
            {
                value: toNano('3.5'),
                bounce: true,
            },
            {
                $$type: 'Enrollment',
                studentIin: OWNER_IIN,
            }
        );
    });

    it('CourseChild is initialized', async () => {
        expect(Boolean(await courseChild.getIsInitialized())).toEqual(true);
    });

    it('CourseChild course_address', async () => {
        expect((await courseChild.getCourseAddress()).toString())
            .toBe((courseParent.address).toString());
    });

    it('CourseChild owner_iin', async () => {
        expect((await courseChild.getOwnerIin()).toString())
            .toBe(OWNER_IIN);
    });
});
