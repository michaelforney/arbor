
commands = aclocal automake
executables = automake-wrapper.sh $(commands)
versions = 1.10 1.9 1.8 1.7 1.6 1.5 1.4 latest

all:: $(commands)

$(commands): % :
	@echo "[LN] automake-wrapper.sh $@"
	ln -s automake-wrapper.sh $@
	chmod +x $@

maintainer-check:: all 
	for command in $(commands); do \
		cp $${command} $${command}-check && \
		sed -e "/^[^#]/s#/usr/bin/#./#" \
			-i $${command}-check && \
		for version in $(versions); do \
			echo -e '#/usr/bin/env bash\n' >$${command}-check-$${version} && \
			echo -e 'version=$$(basename $${0}) && echo $${version/*-}' >$${command}-check-$${version} && \
			chmod +x $${command}-check-$${version} && \
			echo -n "WANT_AUTOMAKE=$${version} ./$${command}-check --version: " && \
			WANT_AUTOMAKE=$${version} ./$${command}-check --version; \
		done; \
	done

clean::
	for command in $(commands); do \
		for version in $(versions); do \
			rm -f $${command} $${command}-check $${command}-check-$${version}; \
		done; \
	done;

