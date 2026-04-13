mkdir -p "$DESTDIR$PREFIX/lib"
cd "$DESTDIR$PREFIX/lib" || exit 1
for lib in pulseaudio/{,modules/}lib*.so*; do
	ln -v -s -f "$lib" "$(basename "$lib")"
done
