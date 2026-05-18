source $AKATSUKI_INSTALL/preflight/guard.sh
source $AKATSUKI_INSTALL/preflight/begin.sh
run_logged $AKATSUKI_INSTALL/preflight/show-env.sh
run_logged $AKATSUKI_INSTALL/preflight/pacman.sh
run_logged $AKATSUKI_INSTALL/preflight/migrations.sh
run_logged $AKATSUKI_INSTALL/preflight/first-run-mode.sh
run_logged $AKATSUKI_INSTALL/preflight/disable-mkinitcpio.sh
