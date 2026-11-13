#!/usr/bin/env python3
"""Build a self-contained local macOS playtest app with the installed Godot runtime.
Uses a PCK export and bundled engine; does not require release export templates.
This is a local development build, not a signed/notarized distribution release.
"""
from pathlib import Path
import plistlib, shutil, subprocess, hashlib
root=Path(__file__).resolve().parents[1]
engine=Path('/Applications/Godot.app/Contents/MacOS/Godot')
build=root/'dist'/'AshenVeil-Playtest.app'
mac=build/'Contents'/'MacOS';resources=build/'Contents'/'Resources'
mac.mkdir(parents=True,exist_ok=True);resources.mkdir(parents=True,exist_ok=True)
subprocess.run([str(engine),'--headless','--path',str(root/'game'),'--editor','--quit'],check=True)
subprocess.run([str(engine),'--headless','--path',str(root/'game'),'--export-pack','macOS',str(resources/'AshenVeil.pck')],check=True)
# Preserve the signed engine bundle (including its matching Info.plist).
# APFS clones share immutable blocks without changing either bundle's contents.
frameworks=build/'Contents'/'Frameworks';frameworks.mkdir(exist_ok=True)
runtime_bundle=frameworks/'Godot.app'
if runtime_bundle.exists():shutil.rmtree(runtime_bundle)
subprocess.run(['cp','-cR',str(engine.parents[2]),str(runtime_bundle)],check=True)
subprocess.run(['codesign','--verify','--deep','--strict',str(runtime_bundle)],check=True)
legacy_runtime=mac/'AshenVeilRuntime'
if legacy_runtime.exists():legacy_runtime.unlink()
launcher=mac/'AshenVeil'
launcher.write_text('#!/bin/sh\napp_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"\nexec "$app_dir/Frameworks/Godot.app/Contents/MacOS/Godot" --main-pack "$app_dir/Resources/AshenVeil.pck" "$@"\n')
launcher.chmod(0o755)
info={'CFBundleExecutable':'AshenVeil','CFBundleIdentifier':'com.qentrah.ashenveil.playtest','CFBundleName':'Ashen Veil Playtest','CFBundleDisplayName':'Ashen Veil Playtest','CFBundlePackageType':'APPL','CFBundleShortVersionString':'0.2.0','CFBundleVersion':'2','NSHighResolutionCapable':True,'LSMinimumSystemVersion':'11.0'}
with (build/'Contents'/'Info.plist').open('wb') as f:plistlib.dump(info,f)
shutil.copytree(root/'game'/'licenses',resources/'licenses',dirs_exist_ok=True)
(resources/'BUILD.txt').write_text('Local playtest build. Bundles Godot 4.7.2 editor runtime and exported project data. No external project path required. Not notarized.\n')
(root/'dist'/'AshenVeil-Playtest.sha256').write_text(hashlib.sha256((resources/'AshenVeil.pck').read_bytes()).hexdigest()+'  AshenVeil-Playtest.app/Contents/Resources/AshenVeil.pck\n')
# The installed engine is already signed; seal the enclosing bundle without
# rewriting the entire nested universal binary on a nearly-full disk.
subprocess.run(["codesign","--force","--sign","-",str(build)],check=True)
subprocess.run(["codesign","--verify","--deep","--strict",str(build)],check=True)
print(build)
