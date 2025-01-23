import { CompilerConfig } from '@ton/blueprint';

export const compile: CompilerConfig = {
    lang: 'tact',
    target: 'contracts/quiz.tact',
    options: {
        debug: true,
    },
};
