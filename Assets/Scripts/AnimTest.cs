using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Animancer;
using Sirenix.OdinInspector;

public class AnimTest : MonoBehaviour
{
    [SerializeField] AnimancerComponent _Animancer;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    [Button("애니메이션 재생 테스트")]
    void DoAnimTest(AnimationClip clip)
    {
        _Animancer.Play(clip);
    }
}
