all: mm3 rm3

mm3:
	rm -f target/mm3hack.nes target/digits_small.bin
	dd if=resources/digits.bin of=target/digits_small.bin bs=256 count=1 2>/dev/null
	cd src && ~/tmp/xkas-plus/xkas main_mm3.asm -ips -o ../ips/mm3hack.ips && cd -
	cp nes/mm3.nes target/mm3hack.nes
	~/tmp/ips.pl target/mm3hack.nes ips/mm3hack.ips 2>/dev/null

rm3:
	rm -f target/rm3hack.nes target/digits_small.bin
	dd if=resources/digits.bin of=target/digits_small.bin bs=256 count=1 2>/dev/null
	cd src && ~/tmp/xkas-plus/xkas main_rm3.asm -ips -o ../ips/rm3hack.ips && cd -
	cp nes/rm3.nes target/rm3hack.nes
	~/tmp/ips.pl target/rm3hack.nes ips/rm3hack.ips 2>/dev/null

clean:
	rm -f target/*
