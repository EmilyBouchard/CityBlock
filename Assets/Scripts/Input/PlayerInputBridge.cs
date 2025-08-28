using DOTS.Components;
using Unity.Entities;
using UnityEngine;
using UnityEngine.InputSystem;

namespace Input
{
    public class PlayerInputBridge : MonoBehaviour
    {
        public InputActionReference move;
        public InputActionReference look;
        public InputActionReference jump;
        public InputActionReference sprint;
        public InputActionReference interact;

        public Vector2 ReadMove() => move.action.ReadValue<Vector2>();
        public Vector2 ReadLook() => look.action.ReadValue<Vector2>();
        public bool ReadJump() => jump.action.WasPerformedThisFrame();
        public bool ReadSprint() => sprint.action.IsPressed();
        public bool ReadInteract() => interact.action.WasPerformedThisFrame();

        void OnEnable()
        {
            move.action.Enable();
            look.action.Enable();
            jump.action.Enable();
            sprint.action.Enable();
            interact.action.Enable();
        }

        void OnDisable()
        {
            move.action.Disable();
            look.action.Disable();
            jump.action.Disable();
            sprint.action.Disable();
            interact.action.Disable();
        }

        void Update()
        {
            var world = World.DefaultGameObjectInjectionWorld;
            if (!world.IsCreated)
                return;

            var entityManager = world.EntityManager;
            var query = entityManager.CreateEntityQuery(typeof(MoveInput));
            if (query.IsEmptyIgnoreFilter)
                return; // or create one here if you prefer

            var entity = query.GetSingletonEntity();
            var data = entityManager.GetComponentData<MoveInput>(entity);

            // ReSharper disable LocalVariableHidesMember
            Vector2 move = ReadMove();
            Vector2 look = ReadLook();
            // ReSharper restore LocalVariableHidesMember
            data.Move = new Unity.Mathematics.float2(move.x, move.y);
            data.Look = new Unity.Mathematics.float2(look.x, look.y);
            data.Jump = (byte)(ReadJump() ? 1 : 0);
            data.Sprint = (byte)(ReadSprint() ? 1 : 0);
            data.Interact = (byte)(ReadInteract() ? 1 : 0);

            entityManager.SetComponentData(entity, data);
        }

    }
}
