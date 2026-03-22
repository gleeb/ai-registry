** new issues


*** Testing
a testing fine was created in the same folder and location of the actual script/file, this is not ideomatic, should we create a skill for testing in various langs? 

Also, test files are created everywhere instead of in designated best practive locations like under test/ folder or something, they are being created next to the implementation file or in the root folder

another serious thing i have with the testing is that agents leave wihtout running all the tests, so they end up passing without trealizing that they broke something etc. this is also wasting tokens because more cycles ned top happen

there is a god damn import error:
'render' is declared but its value is never read.ts(6133)
Cannot find module 'react-native-testing-library' or its corresponding type declarations.ts(2307)
and no one is handling it...!!! (eventually something caught it and it cicled back to the implementor, but why didnt the impelementor run the linter or the tests to fix this out for himself? just wasteful cycles

*** validation
it feels like the acceptance validator and the semantic validator can be combined

git worktrees:
explore, study the material explain it to me, how do i start working with branches and everything...