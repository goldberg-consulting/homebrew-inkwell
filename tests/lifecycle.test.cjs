const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const cp = require('node:child_process');
const cask = path.resolve(__dirname, '../Casks/inkwell.rb');
const ruby = `require 'json'
HOMEBREW_PREFIX = ENV.fetch('TEST_PREFIX')
class CaskFixture
  def initialize; @values = {}; end
  def version(value = nil); value ? @version = value : @version; end
  def staged_path; ENV.fetch('TEST_STAGE'); end
  def installer(**value); @values[:installer] = value; end
  def uninstall(**value); @values[:uninstall] = value; end
  def method_missing(*); end
  def values; @values; end
end
def cask(_name, &block)
  fixture = CaskFixture.new
  fixture.instance_eval(&block)
  puts JSON.generate(fixture.values)
end
load ARGV.first
`;
function fixture(t) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "inkwell tap ' $()-"));
  t.after(() => fs.rmSync(root, {recursive:true, force:true}));
  const stage = path.join(root, 'stage');
  const prefix = path.join(root, 'prefix');
  fs.mkdirSync(stage); fs.mkdirSync(path.join(prefix, 'bin'), {recursive:true});
  fs.symlinkSync(process.execPath, path.join(prefix,'bin/node'));
  const result = cp.spawnSync('ruby',['-e',ruby,cask], {encoding:'utf8',env:{...process.env,TEST_PREFIX:prefix,TEST_STAGE:stage}});
  assert.equal(result.status,0,result.stderr);
  const config = JSON.parse(result.stdout);
  const version = fs.readFileSync(cask,'utf8').match(/version "([^"]+)"/)[1];
  const source = path.join(root,'archive');
  fs.mkdirSync(path.join(source,'extension/out'),{recursive:true});
  fs.writeFileSync(path.join(source,'extension/out/install-cli.js'), `require('fs').writeFileSync(process.env.TEST_TRACE,JSON.stringify(process.argv.slice(2)));process.exit(Number(process.env.TEST_EXIT||0));`);
  const archive = path.join(stage,`inkwell-${version}.vsix`);
  const zipped = cp.spawnSync('/usr/bin/zip',['-qr',archive,'extension'],{cwd:source});
  assert.equal(zipped.status,0);
  const trace = path.join(root,'trace.json');
  const run = (which, extra={}) => {
    const script=config[which].script;
    assert.equal(script.sudo,false);
    return cp.spawnSync(script.executable,script.args,{encoding:'utf8',env:{...process.env,TEST_TRACE:trace,...extra}});
  };
  return {root,stage,archive,version,run,args:()=>JSON.parse(fs.readFileSync(trace,'utf8'))};
}
test('cask installs exact staged bytes through the shared installer with literal paths', t => {
  const f=fixture(t); const result=f.run('installer'); assert.equal(result.status,0,result.stderr);
  assert.deepEqual(f.args(),[`--vsix=${f.archive}`,`--version=${f.version}`,'--editor=auto','--profile=full','--yes']);
});
test('installation failures propagate to Homebrew', t => {
  const f=fixture(t); assert.equal(f.run('installer',{TEST_EXIT:'17'}).status,17);
  fs.writeFileSync(f.archive,'invalid zip'); assert.notEqual(f.run('installer').status,0);
});
test('uninstall uses shared version-aware removal and leaves user files intact', t => {
  const f=fixture(t); assert.equal(f.run('installer').status,0);
  const documents=path.join(f.root,'documents');fs.mkdirSync(documents);
  fs.writeFileSync(path.join(documents,'report.md'),'user content');
  assert.equal(f.run('uninstall').status,0);
  assert.deepEqual(f.args(),[`--vsix=${f.archive}`,`--version=${f.version}`,'--editor=all','--uninstall']);
  assert.equal(fs.readFileSync(path.join(documents,'report.md'),'utf8'),'user content');
  assert.equal(f.run('uninstall',{TEST_EXIT:'18'}).status,18);
});
