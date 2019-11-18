class NodeAT10 < Formula
  desc "Platform built on V8 to build network applications"
  homepage "https://nodejs.org/"
  url "https://nodejs.org/dist/v10.17.0/node-v10.17.0.tar.gz"
  sha256 "5204249d135176b547737d3eed2ca8a9d7f731fef6e545f741129cfa21f90573"

  bottle do
    cellar :any
    sha256 "40dd8d0a63109a7382bb82b8acce2a59dec5e287aa16076a53bef58a69505298" => :catalina
    sha256 "b8065c647630356ba9d8cb1aa08a91084fd2c31068fc26b74641a982b5c6d21b" => :mojave
    sha256 "4d7052b587498a1cda140e1190a274a3e4002e1967dfe5dbc29e1cc286a48733" => :high_sierra
  end

  keg_only :versioned_formula

  depends_on "pkg-config" => :build
  depends_on "python" => :build # does not support Python 3
  depends_on "icu4c"

  # Fixes detecting Apple clang 11.
  patch do
    url "https://github.com/nodejs/node/commit/1f143b8625c2985b4317a40f279232f562417077.patch?full_index=1"
    sha256 "12d8af6647e9a5d81f68f610ad0ed17075bf14718f4d484788baac37a0d3f842"
  end

  # apply upstream Python 3 compatibility patches
  patch do # gyp: pull Python 3 changes from node/node-gyp
    url "https://github.com/nodejs/node/commit/b1db810d501079f767579a241c3f613e8a204294.patch?full_index=1"
    sha256 "cb1d581c5de37b3b21a9f8332a9574a9687f49cfc618bb4e5c34381b210c57e1"
  end

  patch do # gyp: cherrypick more Python3 changes from node-gyp
    url "https://github.com/nodejs/node/commit/d630cc0ec5cac7d31d1fd9fa9f4661a53e51a590.patch?full_index=1"
    sha256 ""
  end

  patch do # tools: fix Python 3 issues in gyp/generator/make.py
    url "https://github.com/nodejs/node/commit/eceebd3ef1f40671073e822910c247a71935cb84.patch?full_index=1"
    sha256 ""
  end

  patch do # tools: port Python 3 compat patches from node-gyp to gyp
    url "https://github.com/nodejs/node/commit/66b953207d6f0e9c98155af97147a731b2e461bd.patch?full_index=1"
    sha256 ""
  end

  patch do # gyp: futurize imput.py to prepare for Python 3
    url "https://github.com/nodejs/node/commit/10bae2ec919b26f2f8be5182f3e751d8e2726ec2.patch?full_index=1"
    sha256 ""
  end

  patch do # tools: make nodedownload.py Python 3 compatible
    url "https://github.com/nodejs/node/commit/31c50e5c17aaca2389fef65b8bb9c4c3a100585a.patch?full_index=1"
    sha256 ""
  end

  patch do # tools: use 'from io import StringIO' in ninja.py
    url "https://github.com/nodejs/node/commit/350975e312b706c9185a94cf0e049b994f60ae22.patch?full_index=1"
    sha256 ""
  end

  patch do # gyp: make StringIO work in ninja.py
    url "https://github.com/nodejs/node/commit/a20a8f48f7b9b8243dd6db03e3fb2cd058208c03.patch?full_index=1"
    sha256 ""
  end

  patch do # tools: fix GYP ninja generator for Python 3
    url "https://github.com/nodejs/node/commit/2f81d59e754b4564db7a3450280612e4e5f9079a.patch?full_index=1"
    sha256 ""
  end

  patch do # tools: fix Python 3 syntax error in mac_tool.py
    url "https://github.com/nodejs/node/commit/9529c6660f5cc0de106a60f78d9dbafb6ccea26a.patch?full_index=1"
    sha256 ""
  end

  patch do # tools: pull xcode_emulation.py from node-gyp
    url "https://github.com/nodejs/node/commit/0673dfc0d8944a37e17fbaa683022f4b9e035577.patch?full_index=1"
    sha256 ""
  end

  # build: support py3 for configure.py https://github.com/nodejs/node/commit/0a63e2d9ff13e2a1935c04bbd7d57d39c36c3884
  # python3 support for configure https://github.com/nodejs/node/commit/0415dd7cb3f43849f9d6f1f8d271b39c4649c3de
  # build: always use strings for compiler version in gyp files https://github.com/nodejs/node/commit/ca10dff0cb23342ba512ae2495291e6457a54edb
  # deps: V8: cherry-pick e3d7f8a [build] update gen-postmortem-metadata for Python 3 https://github.com/nodejs/node/commit/a17d398989b9606e4fdc188cb5988cd669ce5edd
  # fix deps/v8/tools/node/* (use print function) from newer V8 versions
  patch :DATA

  def install
    # make sure subprocesses spawned by make are using our Python 3
    ENV["PYTHON"] = Formula["python"].opt_bin/"python3"

    system "python3", "configure.py", "--prefix=#{prefix}", "--with-intl=system-icu"
    system "make", "install"
  end

  def post_install
    (lib/"node_modules/npm/npmrc").atomic_write("prefix = #{HOMEBREW_PREFIX}\n")
  end

  test do
    path = testpath/"test.js"
    path.write "console.log('hello');"

    output = shell_output("#{bin}/node #{path}").strip
    assert_equal "hello", output
    output = shell_output("#{bin}/node -e 'console.log(new Intl.NumberFormat(\"en-EN\").format(1234.56))'").strip
    assert_equal "1,234.56", output

    output = shell_output("#{bin}/node -e 'console.log(new Intl.NumberFormat(\"de-DE\").format(1234.56))'").strip
    assert_equal "1.234,56", output

    # make sure npm can find node
    ENV.prepend_path "PATH", opt_bin
    ENV.delete "NVM_NODEJS_ORG_MIRROR"
    assert_equal which("node"), opt_bin/"node"
    assert_predicate bin/"npm", :exist?, "npm must exist"
    assert_predicate bin/"npm", :executable?, "npm must be executable"
    npm_args = ["-ddd", "--cache=#{HOMEBREW_CACHE}/npm_cache", "--build-from-source"]
    system "#{bin}/npm", *npm_args, "install", "npm@latest"
    system "#{bin}/npm", *npm_args, "install", "bignum"
    assert_predicate bin/"npx", :exist?, "npx must exist"
    assert_predicate bin/"npx", :executable?, "npx must be executable"
    assert_match "< hello >", shell_output("#{bin}/npx cowsay hello")
  end
end

__END__
diff --git a/configure.py b/configure.py
index 22861a1..c96f8c4 100755
--- a/configure.py
+++ b/configure.py
@@ -11,7 +11,7 @@ import re
 import shlex
 import subprocess
 import shutil
-import string
+import io
 from distutils.spawn import find_executable as which

 # If not run from node/, cd to node/.
@@ -616,11 +616,10 @@ def print_verbose(x):

 def b(value):
   """Returns the string 'true' if value is truthy, 'false' otherwise."""
-  if value:
-    return 'true'
-  else:
-    return 'false'
+  return 'true' if value else 'false'

+def to_utf8(s):
+  return s if isinstance(s, str) else s.decode("utf-8")

 def pkg_config(pkg):
   """Run pkg-config on the specified package
@@ -634,7 +633,7 @@ def pkg_config(pkg):
       proc = subprocess.Popen(
           shlex.split(pkg_config) + ['--silence-errors', flag, pkg],
           stdout=subprocess.PIPE)
-      val = proc.communicate()[0].strip()
+      val = to_utf8(proc.communicate()[0]).strip()
     except OSError as e:
       if e.errno != errno.ENOENT: raise e  # Unexpected error.
       return (None, None, None, None)  # No pkg-config/pkgconf installed.
@@ -649,10 +648,10 @@ def try_check_compiler(cc, lang):
   except OSError:
     return (False, False, '', '')

-  proc.stdin.write('__clang__ __GNUC__ __GNUC_MINOR__ __GNUC_PATCHLEVEL__ '
-                   '__clang_major__ __clang_minor__ __clang_patchlevel__')
+  proc.stdin.write(b'__clang__ __GNUC__ __GNUC_MINOR__ __GNUC_PATCHLEVEL__ '
+                   b'__clang_major__ __clang_minor__ __clang_patchlevel__')

-  values = (proc.communicate()[0].split() + ['0'] * 7)[0:7]
+  values = (to_utf8(proc.communicate()[0]).split() + ['0'] * 7)[0:7]
   is_clang = values[0] == '1'
   gcc_version = tuple(map(int, values[1:1+3]))
   clang_version = tuple(map(int, values[4:4+3])) if is_clang else None
@@ -677,7 +676,7 @@ def get_version_helper(cc, regexp):
        consider adjusting the CC environment variable if you installed
        it in a non-standard prefix.''')

-  match = re.search(regexp, proc.communicate()[1])
+  match = re.search(regexp, to_utf8(proc.communicate()[1]))

   if match:
     return match.group(2)
@@ -696,7 +695,7 @@ def get_nasm_version(asm):
     return '0'

   match = re.match(r"NASM version ([2-9]\.[0-9][0-9]+)",
-                   proc.communicate()[0])
+                   to_utf8(proc.communicate()[0]))

   if match:
     return match.group(1)
@@ -727,7 +726,7 @@ def get_gas_version(cc):
        consider adjusting the CC environment variable if you installed
        it in a non-standard prefix.''')

-  gas_ret = proc.communicate()[1]
+  gas_ret = to_utf8(proc.communicate()[1])
   match = re.match(r"GNU assembler version ([2-9]\.[0-9]+)", gas_ret)

   if match:
@@ -794,10 +793,8 @@ def cc_macros(cc=None):
        consider adjusting the CC environment variable if you installed
        it in a non-standard prefix.''')

-  p.stdin.write('\n')
-  out = p.communicate()[0]
-
-  out = str(out).split('\n')
+  p.stdin.write(b'\n')
+  out = to_utf8(p.communicate()[0]).split('\n')

   k = {}
   for line in out:
@@ -1351,7 +1348,7 @@ def configure_intl(o):
     o['variables']['icu_small'] = b(True)
     locs = set(options.with_icu_locales.split(','))
     locs.add('root')  # must have root
-    o['variables']['icu_locales'] = string.join(locs,',')
+    o['variables']['icu_locales'] = ','.join(str(loc) for loc in locs)
     # We will check a bit later if we can use the canned deps/icu-small
   elif with_intl == 'full-icu':
     # full ICU
@@ -1482,16 +1479,17 @@ def configure_intl(o):
   icu_ver_major = None
   matchVerExp = r'^\s*#define\s+U_ICU_VERSION_SHORT\s+"([^"]*)".*'
   match_version = re.compile(matchVerExp)
-  for line in open(uvernum_h).readlines():
-    m = match_version.match(line)
-    if m:
-      icu_ver_major = m.group(1)
+  with io.open(uvernum_h, encoding='utf8') as in_file:
+    for line in in_file:
+      m = match_version.match(line)
+      if m:
+        icu_ver_major = str(m.group(1))
   if not icu_ver_major:
     error('Could not read U_ICU_VERSION_SHORT version from %s' % uvernum_h)
   elif int(icu_ver_major) < icu_versions['minimum_icu']:
     error('icu4c v%s.x is too old, v%d.x or later is required.' %
           (icu_ver_major, icu_versions['minimum_icu']))
-  icu_endianness = sys.byteorder[0];
+  icu_endianness = sys.byteorder[0]
   o['variables']['icu_ver_major'] = icu_ver_major
   o['variables']['icu_endianness'] = icu_endianness
   icu_data_file_l = 'icudt%s%s.dat' % (icu_ver_major, 'l')
diff --git a/configure.py.orig b/configure.py.orig
index cfd4207..22861a1 100755
--- a/configure.py.orig
+++ b/configure.py.orig
@@ -709,7 +709,7 @@ def get_llvm_version(cc):

 def get_xcode_version(cc):
   return get_version_helper(
-    cc, r"(^Apple LLVM version) ([0-9]+\.[0-9]+)")
+    cc, r"(^Apple (?:clang|LLVM) version) ([0-9]+\.[0-9]+)")

 def get_gas_version(cc):
   try:
diff --git a/deps/v8/tools/node/fetch_deps.py b/deps/v8/tools/node/fetch_deps.py
index 26b9d6a..8bc2133 100755
--- a/deps/v8/tools/node/fetch_deps.py
+++ b/deps/v8/tools/node/fetch_deps.py
@@ -51,9 +51,9 @@ def EnsureGit(v8_path):
   expected_git_dir = os.path.join(v8_path, ".git")
   actual_git_dir = git("rev-parse --absolute-git-dir")
   if expected_git_dir == actual_git_dir:
-    print "V8 is tracked stand-alone by git."
+    print("V8 is tracked stand-alone by git.")
     return False
-  print "Initializing temporary git repository in v8."
+  print("Initializing temporary git repository in v8.")
   git("init")
   git("config user.name \"Ada Lovelace\"")
   git("config user.email ada@lovela.ce")
@@ -70,7 +70,7 @@ def FetchDeps(v8_path):

   temporary_git = EnsureGit(v8_path)
   try:
-    print "Fetching dependencies."
+    print("Fetching dependencies.")
     env = os.environ.copy()
     # gclient needs to have depot_tools in the PATH.
     env["PATH"] = depot_tools + os.pathsep + env["PATH"]


diff --git a/deps/v8/tools/node/node_common.py b/deps/v8/tools/node/node_common.py
index de2e98d..860c606 100755
--- a/deps/v8/tools/node/node_common.py
+++ b/deps/v8/tools/node/node_common.py
@@ -22,7 +22,7 @@ def EnsureDepotTools(v8_path, fetch_if_not_exist):
     except:
       pass
     if fetch_if_not_exist:
-      print "Checking out depot_tools."
+      print("Checking out depot_tools.")
       # shell=True needed on Windows to resolve git.bat.
       subprocess.check_call("git clone {} {}".format(
           pipes.quote(DEPOT_TOOLS_URL),
@@ -31,14 +31,14 @@ def EnsureDepotTools(v8_path, fetch_if_not_exist):
     return None
   depot_tools = _Get(v8_path)
   assert depot_tools is not None
-  print "Using depot tools in %s" % depot_tools
+  print("Using depot tools in %s" % depot_tools)
   return depot_tools

 def UninitGit(v8_path):
-  print "Uninitializing temporary git repository"
+  print("Uninitializing temporary git repository")
   target = os.path.join(v8_path, ".git")
   if os.path.isdir(target):
-    print ">> Cleaning up %s" % target
+    print(">> Cleaning up %s" % target)
     def OnRmError(func, path, exec_info):
       # This might happen on Windows
       os.chmod(path, stat.S_IWRITE)
diff --git a/deps/v8/gypfiles/toolchain.gypi b/deps/v8/gypfiles/toolchain.gypi
index fbf6832..1829ebe 100644
--- a/deps/v8/gypfiles/toolchain.gypi
+++ b/deps/v8/gypfiles/toolchain.gypi
@@ -41,7 +41,7 @@
     'has_valgrind%': 0,
     'coverage%': 0,
     'v8_target_arch%': '<(target_arch)',
-    'v8_host_byteorder%': '<!(python -c "import sys; print sys.byteorder")',
+    'v8_host_byteorder%': '<!(python -c "import sys; print(sys.byteorder)")',
     'force_dynamic_crt%': 0,

     # Setting 'v8_can_use_vfp32dregs' to 'true' will cause V8 to use the VFP
diff --git a/configure.py b/configure.py
index 5d57338..2e35801 100755
--- a/configure.py
+++ b/configure.py
@@ -681,7 +681,7 @@ def get_version_helper(cc, regexp):
   if match:
     return match.group(2)
   else:
-    return '0'
+    return '0.0'

 def get_nasm_version(asm):
   try:
@@ -692,7 +692,7 @@ def get_nasm_version(asm):
     warn('''No acceptable ASM compiler found!
          Please make sure you have installed NASM from http://www.nasm.us
          and refer BUILDING.md.''')
-    return '0'
+    return '0.0'

   match = re.match(r"NASM version ([2-9]\.[0-9][0-9]+)",
                    to_utf8(proc.communicate()[0]))
@@ -700,7 +700,7 @@ def get_nasm_version(asm):
   if match:
     return match.group(1)
   else:
-    return '0'
+    return '0.0'

 def get_llvm_version(cc):
   return get_version_helper(
@@ -733,7 +733,7 @@ def get_gas_version(cc):
     return match.group(1)
   else:
     warn('Could not recognize `gas`: ' + gas_ret)
-    return '0'
+    return '0.0'

 # Note: Apple clang self-reports as clang 4.2.0 and gcc 4.2.1.  It passes
 # the version check more by accident than anything else but a more rigorous
@@ -744,7 +744,7 @@ def check_compiler(o):
     if not options.openssl_no_asm and options.dest_cpu in ('x86', 'x64'):
       nasm_version = get_nasm_version('nasm')
       o['variables']['nasm_version'] = nasm_version
-      if nasm_version == 0:
+      if nasm_version == '0.0':
         o['variables']['openssl_no_asm'] = 1
     return

@@ -765,7 +765,7 @@ def check_compiler(o):
     # to a version that is not completely ancient.
     warn('C compiler too old, need gcc 4.2 or clang 3.2 (CC=%s)' % CC)

-  o['variables']['llvm_version'] = get_llvm_version(CC) if is_clang else 0
+  o['variables']['llvm_version'] = get_llvm_version(CC) if is_clang else '0.0'

   # Need xcode_version or gas_version when openssl asm files are compiled.
   if options.without_ssl or options.openssl_no_asm or options.shared_openssl:
diff --git a/configure.py.orig b/configure.py.orig
index 22861a1..5d57338 100755
--- a/configure.py.orig
+++ b/configure.py.orig
@@ -11,7 +11,7 @@ import re
 import shlex
 import subprocess
 import shutil
-import string
+import io
 from distutils.spawn import find_executable as which

 # If not run from node/, cd to node/.
@@ -616,11 +616,10 @@ def print_verbose(x):

 def b(value):
   """Returns the string 'true' if value is truthy, 'false' otherwise."""
-  if value:
-    return 'true'
-  else:
-    return 'false'
+  return 'true' if value else 'false'

+def to_utf8(s):
+  return s if isinstance(s, str) else s.decode("utf-8")

 def pkg_config(pkg):
   """Run pkg-config on the specified package
@@ -634,7 +633,7 @@ def pkg_config(pkg):
       proc = subprocess.Popen(
           shlex.split(pkg_config) + ['--silence-errors', flag, pkg],
           stdout=subprocess.PIPE)
-      val = proc.communicate()[0].strip()
+      val = to_utf8(proc.communicate()[0]).strip()
     except OSError as e:
       if e.errno != errno.ENOENT: raise e  # Unexpected error.
       return (None, None, None, None)  # No pkg-config/pkgconf installed.
@@ -649,10 +648,10 @@ def try_check_compiler(cc, lang):
   except OSError:
     return (False, False, '', '')

-  proc.stdin.write('__clang__ __GNUC__ __GNUC_MINOR__ __GNUC_PATCHLEVEL__ '
-                   '__clang_major__ __clang_minor__ __clang_patchlevel__')
+  proc.stdin.write(b'__clang__ __GNUC__ __GNUC_MINOR__ __GNUC_PATCHLEVEL__ '
+                   b'__clang_major__ __clang_minor__ __clang_patchlevel__')

-  values = (proc.communicate()[0].split() + ['0'] * 7)[0:7]
+  values = (to_utf8(proc.communicate()[0]).split() + ['0'] * 7)[0:7]
   is_clang = values[0] == '1'
   gcc_version = tuple(map(int, values[1:1+3]))
   clang_version = tuple(map(int, values[4:4+3])) if is_clang else None
@@ -677,7 +676,7 @@ def get_version_helper(cc, regexp):
        consider adjusting the CC environment variable if you installed
        it in a non-standard prefix.''')

-  match = re.search(regexp, proc.communicate()[1])
+  match = re.search(regexp, to_utf8(proc.communicate()[1]))

   if match:
     return match.group(2)
@@ -696,7 +695,7 @@ def get_nasm_version(asm):
     return '0'

   match = re.match(r"NASM version ([2-9]\.[0-9][0-9]+)",
-                   proc.communicate()[0])
+                   to_utf8(proc.communicate()[0]))

   if match:
     return match.group(1)
@@ -727,7 +726,7 @@ def get_gas_version(cc):
        consider adjusting the CC environment variable if you installed
        it in a non-standard prefix.''')

-  gas_ret = proc.communicate()[1]
+  gas_ret = to_utf8(proc.communicate()[1])
   match = re.match(r"GNU assembler version ([2-9]\.[0-9]+)", gas_ret)

   if match:
@@ -794,10 +793,8 @@ def cc_macros(cc=None):
        consider adjusting the CC environment variable if you installed
        it in a non-standard prefix.''')

-  p.stdin.write('\n')
-  out = p.communicate()[0]
-
-  out = str(out).split('\n')
+  p.stdin.write(b'\n')
+  out = to_utf8(p.communicate()[0]).split('\n')

   k = {}
   for line in out:
@@ -1351,7 +1348,7 @@ def configure_intl(o):
     o['variables']['icu_small'] = b(True)
     locs = set(options.with_icu_locales.split(','))
     locs.add('root')  # must have root
-    o['variables']['icu_locales'] = string.join(locs,',')
+    o['variables']['icu_locales'] = ','.join(str(loc) for loc in locs)
     # We will check a bit later if we can use the canned deps/icu-small
   elif with_intl == 'full-icu':
     # full ICU
@@ -1482,16 +1479,17 @@ def configure_intl(o):
   icu_ver_major = None
   matchVerExp = r'^\s*#define\s+U_ICU_VERSION_SHORT\s+"([^"]*)".*'
   match_version = re.compile(matchVerExp)
-  for line in open(uvernum_h).readlines():
-    m = match_version.match(line)
-    if m:
-      icu_ver_major = m.group(1)
+  with io.open(uvernum_h, encoding='utf8') as in_file:
+    for line in in_file:
+      m = match_version.match(line)
+      if m:
+        icu_ver_major = str(m.group(1))
   if not icu_ver_major:
     error('Could not read U_ICU_VERSION_SHORT version from %s' % uvernum_h)
   elif int(icu_ver_major) < icu_versions['minimum_icu']:
     error('icu4c v%s.x is too old, v%d.x or later is required.' %
           (icu_ver_major, icu_versions['minimum_icu']))
-  icu_endianness = sys.byteorder[0];
+  icu_endianness = sys.byteorder[0]
   o['variables']['icu_ver_major'] = icu_ver_major
   o['variables']['icu_endianness'] = icu_endianness
   icu_data_file_l = 'icudt%s%s.dat' % (icu_ver_major, 'l')
diff --git a/deps/openssl/openssl.gyp b/deps/openssl/openssl.gyp
index 60f6ee0..0ca7515 100644
--- a/deps/openssl/openssl.gyp
+++ b/deps/openssl/openssl.gyp
@@ -1,8 +1,8 @@
 {
   'variables': {
-    'gas_version%': 0,
-    'llvm_version%': 0,
-    'nasm_version%': 0,
+    'gas_version%': '0.0',
+    'llvm_version%': '0.0',
+    'nasm_version%': '0.0',
   },
   'targets': [
     {
diff --git a/tools/gyp/pylib/gyp/input.py b/tools/gyp/pylib/gyp/input.py
index a571b07..913f13d 100644
--- a/tools/gyp/pylib/gyp/input.py
+++ b/tools/gyp/pylib/gyp/input.py
@@ -2284,7 +2284,7 @@ def SetUpConfigurations(target, target_dict):
         merged_configurations[configuration])

   # Now drop all the abstract ones.
-  for configuration in target_dict['configurations'].keys():
+  for configuration in list(target_dict['configurations']):
     old_configuration_dict = target_dict['configurations'][configuration]
     if old_configuration_dict.get('abstract'):
       del target_dict['configurations'][configuration]
diff --git a/deps/v8/tools/gen-postmortem-metadata.py b/deps/v8/tools/gen-postmortem-metadata.py
index db4c6c236580..b5aba23220ba 100644
--- a/deps/v8/tools/gen-postmortem-metadata.py
+++ b/deps/v8/tools/gen-postmortem-metadata.py
@@ -624,7 +619,7 @@ def emit_set(out, consts):
 # Emit the whole output file.
 #
 def emit_config():
-        out = file(sys.argv[1], 'w');
+        out = open(sys.argv[1], 'w');

         out.write(header);

@@ -653,9 +653,7 @@ def emit_config():

         out.write('/* class type information */\n');
         consts = [];
-        keys = typeclasses.keys();
-        keys.sort();
-        for typename in keys:
+        for typename in sorted(typeclasses):
                 klass = typeclasses[typename];
                 consts.append({
                     'name': 'type_%s__%s' % (klass, typename),
@@ -666,9 +664,7 @@ def emit_config():

         out.write('/* class hierarchy information */\n');
         consts = [];
-        keys = klasses.keys();
-        keys.sort();
-        for klassname in keys:
+        for klassname in sorted(klasses):
                 pklass = klasses[klassname]['parent'];
                 bklass = get_base_class(klassname);
                 if (bklass != 'Object'):
