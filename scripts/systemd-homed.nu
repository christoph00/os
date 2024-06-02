#!/usr/bin/env -S nu

cd /tmp

run-external "dnf" "-y" "install" "policycoreutils-devel" "selinux-policy-devel" "setools-console"
echo "Necessary packages installed."
run-external "git" "clone" "https://github.com/richiedaze/homed-selinux.git"
echo "SELinux rules repo cloned."
cd homed-selinux
run-external "make" "-f" "/usr/share/selinux/devel/Makefile" "homed.pp"
echo "SELinux rules built."
run-external "semodule" "--install=homed.pp"
echo "SELinux rules installed."
run-external restorecon -rv \
    /usr/lib/systemd/systemd-homed \
    /usr/lib/systemd/systemd-homework \
    /usr/lib/systemd/system/systemd-homed.service \
    /usr/lib/systemd/system/systemd-homed-activate.service \
    /var/lib/systemd/home
echo "SELinux rules applied."
run-external authselect enable-feature with-systemd-homed
echo "Authselect support for systemd-homed enabled."
cd ..
rm -r homed-selinux
run-external dnf -y autoremove policycoreutils-devel selinux-policy-devel setools-console
echo "enable systemd-homed"
run-external systemctl enable systemd-homed