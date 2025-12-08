#!/bin/bash
set -e

# Color definitions
BOLD='\033[1m'
DIM='\033[2m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi

echo -e "${BOLD}Nvidia GPU Status${NC}"
echo ""
nvidia-smi || echo -e "${DIM}nvidia-smi not available${NC}"
echo ""

echo -e "${BOLD}Environment Info${NC}"
echo ""
python3 -c "import torch; print(f'${CYAN}PyTorch:${NC} {torch.__version__}')" 2>/dev/null || echo -e "${DIM}PyTorch not available${NC}"
python3 -c "import torch; print(f'${CYAN}CUDA Available:${NC} {torch.cuda.is_available()}'); print(f'${CYAN}CUDA Version:${NC} {torch.version.cuda if torch.cuda.is_available() else \"N/A\"}')" 2>/dev/null || echo -e "${DIM}CUDA info not available${NC}"
echo ""

echo -e "${BOLD}ROS2 Quick Commands${NC}"
echo ""
echo -e "${DIM}Available aliases:${NC}"
echo -e "  ${YELLOW}cbs${NC}    - colcon build --symlink-install"
echo -e "  ${YELLOW}src${NC}    - source ~/ros2_ws/install/setup.bash"
echo -e "  ${YELLOW}rmbil${NC}  - rm -fr build install log"
echo ""

echo -e "${BOLD}Contact-GraspNet Quick Start${NC}"
echo ""
echo -e "${DIM}To run Contact-GraspNet inference:${NC}"
echo -e "${GREEN}cd${NC} \$HOME/contact_graspnet_pytorch"
echo -e "${GREEN}python3${NC} -m contact_graspnet_pytorch.inference \\"
echo -e "    --np_path=\"test_data/*.npy\" \\"
echo -e "    --local_regions \\"
echo -e "    --filter_grasps"
echo ""

exec "$@"