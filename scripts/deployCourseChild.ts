import { toNano } from '@ton/core';
import { CourseChild } from '../wrappers/CourseChild';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const courseChild = provider.open(await CourseChild.fromInit());

    await courseChild.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(courseChild.address);

    // run methods on `courseChild`
}
