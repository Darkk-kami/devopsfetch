module.exports = {
  branches: [
    { name: 'main' },
    { name: 'staging', prerelease: 'rc' },
  ],
  plugins: [
    '@semantic-release/commit-analyzer',
    '@semantic-release/release-notes-generator',
    [
      '@semantic-release/npm',
      { npmPublish: false },
    ],
    '@semantic-release/github',
    [
      '@semantic-release/git',
      {
        assets: ['package.json'],
        message: 'chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}',
      },
    ],
  ],
};

