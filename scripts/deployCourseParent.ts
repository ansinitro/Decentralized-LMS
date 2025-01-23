import { toNano } from '@ton/core';
import { CourseParent } from '../wrappers/CourseParent';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const courseParent = provider.open(await CourseParent.fromInit(0n));

    await courseParent.send(
        provider.sender(),
        {
            value: toNano('0.15'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(courseParent.address);

    // run methods on `courseParent`
}
