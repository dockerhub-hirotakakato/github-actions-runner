module.exports = async ({github, context, core, exec}) => {
  const image_name = require('fs').readFileSync('Dockerfile').toString().match(/^FROM +([^ \n]+)/)[1];
  const image_id   =  (await exec.getExecOutput('sh', ['-c', `docker inspect -f {{.Id}} $(docker pull -q ${image_name})`])).stdout.trim();

  const app_repo    = 'actions/runner';
  const app_version = (await github.rest.repos.getLatestRelease({
    owner: app_repo.replace(/\/.+$/, ''),
    repo:  app_repo.replace(/^.+\//, ''),
  })).data.tag_name;

  const cache = JSON.stringify({
    [image_name]: image_id,
    [app_repo]:   app_version,
  });

  const owner = context.repo.owner;
  const repo  = context.repo.repo;

  const release = (await github.rest.repos.listReleases({
    owner: owner,
    repo:  repo,
  })).data.find(r => r.name === 'cache');

  github.rest.repos.updateRelease({
    owner:      owner,
    repo:       repo,
    release_id: release.id,
    body:       cache,
  });

  core.setOutput('no-cache', Boolean(release.body !== cache || (context.payload.inputs && context.payload.inputs['no-cache'])));
  core.setOutput('tags',     `${owner.replace('dockerhub-', '')}/${repo}:${context.ref.replace(/^.+\//, '')}`);
};
