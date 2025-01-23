import { toNano } from '@ton/core';
import { Quiz } from '../wrappers/Quiz';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const quiz = provider.open(await Quiz.fromInit());

    await quiz.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(quiz.address);

    // run methods on `quiz`
}
