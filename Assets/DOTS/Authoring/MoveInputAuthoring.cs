using DOTS.Components;
using Unity.Entities;
using UnityEngine;

namespace DOTS.Authoring
{
    public class MoveInputAuthoring : MonoBehaviour
    {
        class Baker : Baker<MoveInputAuthoring>
        {
            public override void Bake(MoveInputAuthoring a)
            {
                var e = GetEntity(TransformUsageFlags.None);
                AddComponent<MoveInput>(e);
            }
        }
    }
}
