using Unity.Entities;
using Unity.Mathematics;

namespace DOTS.Components
{
    public struct MoveInput : IComponentData
    {
        public float2 Move;
        public float2 Look;
        public byte Jump;
        public byte Sprint;
        public byte Interact;
    }
}
