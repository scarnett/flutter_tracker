module.exports = {
	transform: {
		'^.+\\.tsx?$': 'ts-jest'
		// '^.+\\.tsx?$': '<rootDir>/node_modules/ts-jest/preprocessor.js'
	},
	testRegex: '/tests/.*\\.(ts|tsx|js)$',
	testPathIgnorePatterns: ['lib/', 'node_modules/'],
	moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json', 'node'],
	testEnvironment: 'node',
	rootDir: '.',
}
